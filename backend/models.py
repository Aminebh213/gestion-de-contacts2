from sqlalchemy import Column, Integer, String, ForeignKey
from database import Base
from pydantic import BaseModel

class Person(Base):
    __tablename__ = "persons"
    
    id = Column(Integer, primary_key=True, index=True)
    nom = Column(String, index=True)
    prenom = Column(String, index=True)
    telephone = Column(String, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)


class PersonCreate(BaseModel):
    nom: str
    prenom: str
    telephone: str
    user_id: int


class PersonResponse(BaseModel):
    id: int
    nom: str
    prenom: str
    telephone: str
    user_id: int
    
    class Config:
        from_attributes = True


class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    nom = Column(String, index=True)
    prenom = Column(String, index=True)
    numero = Column(String, unique=True, index=True)
    mot_de_passe = Column(String)


class UserCreate(BaseModel):
    nom: str
    prenom: str
    numero: str
    mot_de_passe: str


class UserLogin(BaseModel):
    numero: str
    mot_de_passe: str
    

class UserResponse(BaseModel):
    id: int
    nom: str
    prenom: str
    numero: str
    
    class Config:
        from_attributes = True

