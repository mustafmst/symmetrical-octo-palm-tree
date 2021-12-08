import os
from flask import Flask, render_template, session, request, redirect, url_for

app = Flask(__name__)

app.secret_key = os.environ.get('SECRET_KEY', 'gtth5thbdh534yht5rhy5yh%#$ha24')


@app.route("/", methods=['GET'])
def index():
    print(session.get('username', None))
    return render_template('index.html', username=session.get('username', None))


@app.route("/login", methods=['GET','POST'])
def login():
    if request.method == 'POST':
        session['username'] = request.form['username']
        print(session)
    if 'username' in session:
        return redirect(url_for('index'))
    return render_template('login.html')


@app.route("/logout", methods=['GET'])
def logout():
    session.pop('username', None)
    return redirect(url_for('index'))

