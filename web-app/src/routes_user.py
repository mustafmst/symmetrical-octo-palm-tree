from flask import render_template, session, request, redirect, url_for, Blueprint

from db_entities import User
from utils import check_password


blueprint = Blueprint(name='user', import_name=__name__)


@blueprint.route("/login", methods=['GET', 'POST'])
def login():
    warnings = []
    if request.method == 'POST':
        user = User.select().where(User.username == request.form['username']).get_or_none()
        if User.select().where(User.username == request.form['username']).get_or_none():
            warnings.append(f"User not exists or wrong password.")
        if len(warnings) is 0 and check_password(request.form['password'], user.password_hash):
            session['username'] = user.username
        else:
            warnings.append(f"User not exists or wrong password.")
    if 'username' in session:
        return redirect(url_for('index'))
    return render_template('login.html', warnings=warnings)


@blueprint.route("/logout", methods=['GET'])
def logout():
    session.pop('username', None)
    return redirect(url_for('index'))


@blueprint.route("/register", methods=['GET', 'POST'])
def register():
    warnings = []
    if request.method == 'POST':
        if User.select().where(User.username == request.form['username']).get_or_none():
            warnings.append(f"User {request.form['username']} already exists.")
        if request.form['username'].strip() == "":
            warnings.append(f"Empty username")
        if len(request.form['password']) < 8:
            warnings.append(f"Password should be at least 8 characters long")
        if len(warnings) is 0:
            user = User.create(username=request.form['username'], password=request.form['password'])
            user.save()
            return redirect(url_for('user.login'))
    return render_template('register.html', warnings=warnings)
