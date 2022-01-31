import os

from flask import Flask, render_template, session

from db_entities import User, db
from src.routes_user import blueprint as users_blueprint

app = Flask(__name__)
app.register_blueprint(users_blueprint)

app.secret_key = os.environ.get('SECRET_KEY', 'gtth5thbdh534yht5rhy5yh%#$ha24')

db.connect()
db.create_tables([User])


@app.route("/", methods=['GET'])
def index():
    print(session.get('username', None))
    return render_template('index.html', username=session.get('username', None))


if __name__ == '__main__':
    app.run()


