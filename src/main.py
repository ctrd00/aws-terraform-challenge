import os

from flask import Flask, render_template, request, redirect, url_for, jsonify

app = Flask(__name__)

if app.debug:
    from . import mock_ssm_client as ssm_client
    SYS_PASS = "DebugPass"
else:
    from . import ssm_client
    SYS_PASS = os.environ.get("SYS_PASS")


@app.route("/hello")
def v_hello():
    return jsonify( {"status": "ok", "message": "hello"} )


@app.route("/")
def v_index():
    ds = ssm_client.get_dynamic_string()
    return render_template('index.html', ds=ds)


@app.route("/set-ds", methods=['GET', 'POST'])
def v_setds():

    current_ds = ssm_client.get_dynamic_string()

    if request.method == 'GET':
        return render_template('setds.html', ds=current_ds)

    ds = request.form.get("ds")
    token = request.form.get("token")

    if token != SYS_PASS:
        return "Error: Invalid Authentication", 401

    if not ds:
        return "Error: Missing value for Dynamic String", 400

    if ds == current_ds:
        return "Warning: Dynamic String was not modified"

    ssm_client.set_dynamic_string(ds)
    return redirect(url_for('v_setds'))
