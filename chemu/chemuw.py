from math import isnan
from urllib import request
from flask import Flask, render_template, jsonify, request, session, redirect, url_for

import chemu

app = Flask(__name__)

# app.config['SESSION_TYPE'] = 'memcached'
# we would change this if the server was accessible by other machines
# having a key set is required when using the 'session' variable
app.config['SECRET_KEY'] = 'super secret key' 

app.config['UPLOAD_FOLDER'] = "/uploads"
app.config['MAX_CONTENT_PATH'] = 65536

def init_flags():
    names = ['n', 'z', 'c', 'u', 'v', 'os']
    session['flag_names'] = names
    flags = {}
    for name in names:
        flags[name] = 0
    return flags

def init_regs():
    names = ['r'] * 13 + ['sp', 'lr', 'pc', 'cpsr']
    for i in range(13):
        names[i] += str(i)
    regs = []
    for name in names:
        reg = {}
        reg['value'] = '0x00000000'
        reg['int'] = 0
        reg['float'] = 0.0
        reg['name'] = name
        regs.append(reg)
    return regs

def update_flags(flags_update):
    flags = session['flags']
    for update in flags_update:
        flags[update['flag']] = update['value']

def update_registers(regs):
    registers = session['registers']
    for reg in regs:
        fval = reg['float']
        if isnan(fval):
            fval = 'NaN'
        else:
            fval = str(round(fval, 2))
        ival = reg['int']
        hexval = reg['value']
        register = registers[reg['register']]
        register['int'] = ival
        register['float'] = reg['float'] = fval
        register['value'] = hexval
    return registers

# breaks instruction output into instruction updates for the web ui
def parse_instructions(instrs):
    for i, instruction_listing in enumerate(instrs):
        addr = instruction_listing['instruction'][:10]
        instr = instruction_listing['instruction'][12:]
        if i == 5:
            instr = instr[:-5]
        instruction_listing['instruction'] = instr
        instruction_listing['address'] = addr

    if instrs[5]['instruction'][0] == 'b':
        # we have a branch condition...
        for i in range(6, 11):
            instr = instrs[i]['instruction']
            split_point = instr.index(':', 6)
            if split_point < 0:
                continue
            left = instr[:split_point-10]
            right_add = instr[split_point-10:split_point]
            right_instr = instr[split_point+2:]
            instrs[i]['instruction'] = left
            right = { 'instruction': right_instr, 'address': right_add }
            instrs.append(right)
    fill = 16 - len(instrs)
    branch = fill == 0
    for i in range(fill):
        instrs.append({ 'address': '', 'instruction': '' })
    return instrs, branch

# method called when the app starts
@app.before_first_request
def session_init():
    session['initialized'] = False

def init_chemu(input_filename, os_filename):
    # initialize the emulator
    result = chemu.init(input_filename, os_filename)
    floaties = result['floaties']

    instructions, branch = parse_instructions(result['instructions'])
    session['command-history'] = []
    
    session['instructions'] = instructions
    registers = session['registers'] = init_regs()

    session['flags'] = init_flags()
    update_flags(result['flags'])

    output = session['output'] = []

    for s in result['output']:
        output.append(s)
    output.append('% pl')
    update_registers(result['registers'])
    session['initialized'] = True

@app.route('/init', methods=['GET', 'POST'])
def pick_files():
    if request.method == 'GET':
        return render_template('filepicker.html')
    elif request.method == "POST":
        os = request.form['os-choice']
        print(os)
        if os == 'none':
            os = None
        elif os == 'default':
            os = 'os.o'
        else:
            os_file = request.files['os-file']
            os = 'uploads/' + os_file.filename
            os_file.save(os)
        f = request.files['input-file']
        fname = 'uploads/' + f.filename
        file = fname
        f.save(fname)
        init_chemu(fname, os)
        return redirect(url_for('home'))

@app.route('/', methods=['GET', 'POST'])
def home():
    # Has the user chosen input files? If not, redirect them to that page
    if 'initialized' not in session or session['initialized'] != True:
        return redirect(url_for('pick_files'))
    
    # we receive POST if the user sent a command using the web interface, 
    #   GET if they simply loaded the page in their browser
    if request.method == 'POST':
        output = session['output']

        command = request.get_json()['command']
        ch = session['command-history']
        ch.append(command)

        # cap command to 32 characters (don't need massive strings)
        if len(command) > 32:
            command = command[:32]
        result = chemu.do(command)

        registers = update_registers(result['registers'])
        branch = False
        halted = False
        dump = []
        l_instructions = []
        if not result['registers'] and ((command[0] == 's' and command[1] == ' ') or (command[0] == 's' and command[1] == 'm' and command[2] == ' ')):
            # emulator halted if no registers were updated on a step command
            # sm and st are commands with command[1] != ' '
            halted = True
            # try to detect branch-to-self (may be overzealous and catch false positives)
            if not result['output'][-1].startswith("Illegal instruction:"):
                result['output'].append('Execution halted: branch to self')
        elif command == 'd' or command.startswith('d '):
            # dump countered
            dump_raw = result['output'][1:]
            result['output'] = result['output'][:1]
            for line in dump_raw:
                addr, addr_dec, val0, val4, val8, valc = line.split()
                dump_row = {}
                dump_row['address'] = addr
                dump_row['values'] = [val0, val4, val8, valc]
                dump.append(dump_row)
            halted = True
        elif command == 'l' or command.startswith('l '):
            instr_raw = result['output'][1:]
            result['output'] = result['output'][:1]
            for line in instr_raw:
                address, hex, instruction = line.split(maxsplit=2)
                l_row = {}
                l_row['address'] = address[:10]
                l_row['hex'] = hex[:10]
                l_row['instruction'] = instruction
                l_instructions.append(l_row)
            halted = True
        else:
            instructions, branch = parse_instructions(result['instructions'])
            session['instructions'] = instructions
        for s in result['output']:
            output.append(s)
        session['output'] = output
        session.modified = True
        return jsonify(
                register_updates=result['registers'], 
                instruction_frame=result['instructions'], 
                output=result['output'], 
                halt=halted, 
                branch=branch,
                flags=result['flags'],
                dump=dump,
                ldump=l_instructions,
                dumpUpdates = result['dumpupdates'],
                messages=result['floaties'])
    else:
        # user loaded the webpage
        instructions = session['instructions']
        # make branch area blank if not on a branch instruction
        fill = 16 - len(instructions)
        for i in range(fill):
            instructions.append({ 'address': '', 'instruction': '' })

        registers = session['registers']
        output = session['output']
        print(session['command-history'])
        return render_template('index.html', 
                registers=registers, 
                instructions=instructions, 
                output=output,
                flags=session['flags'],
                flag_names=session['flag_names'],
                command_history=session['command-history'])

@app.route('/commandhistory', methods=['POST'])
def fetch_command_history():
    return jsonify(command_history=session['command-history'])

@app.route('/reinitialize')
def reinitialize():
    session.clear()
    chemu.reset()
    return redirect(url_for('pick_files'))
