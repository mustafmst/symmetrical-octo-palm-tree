import os
from flask import Flask, render_template, session, request, redirect, url_for

from src.db_entities import User
from src.utils import check_password

app = Flask(__name__)

app.secret_key = os.environ.get('SECRET_KEY', 'gtth5thbdh534yht5rhy5yh%#$ha24')


@app.route("/", methods=['GET'])
def index():
    print(session.get('username', None))
    return render_template('index.html', username=session.get('username', None))


@app.route("/login", methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        user = User.get(User.username == request.form['username'])
        if check_password(request.form['password'], user.password_hash):
            session['username'] = user.username
    if 'username' in session:
        return redirect(url_for('index'))
    return render_template('login.html')


@app.route("/logout", methods=['GET'])
def logout():
    session.pop('username', None)
    return redirect(url_for('index'))


@app.route("/register", methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        user = User.create(username=request.form['username'], password=request.form['password'])
        user.save()
        return redirect(url_for('index'))
    else:
        return render_template('register.html')


