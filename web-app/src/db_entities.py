from peewee import *

from src.utils import hash_password

db = SqliteDatabase('test.db')


class BaseModel(Model):
    class Meta:
        database = db


class User(BaseModel):
    username = CharField(unique=True)
    password_hash = CharField()

    @classmethod
    def create(cls, **query):
        query["password_hash"] = hash_password(query["password"])
        return super(User, cls).create(**query)
