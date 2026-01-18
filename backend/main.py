from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import bcrypt
import uvicorn

from database import engine, get_db
from models import (
    Base,
    Person,
    PersonCreate,
    PersonResponse,
    User,
    UserCreate,
    UserLogin,
    UserResponse,
)

# ================== PASSWORD UTILS ==================

def hash_password(password: str) -> str:
    return bcrypt.hashpw(
        password.encode("utf-8"),
        bcrypt.gensalt()
    ).decode("utf-8")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(
        plain_password.encode("utf-8"),
        hashed_password.encode("utf-8")
    )

# ================== APP INIT ==================

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Contact API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ================== PERSON ROUTES ==================

@app.post("/personnes", response_model=PersonResponse)
def create_person(person: PersonCreate, db: Session = Depends(get_db)):
    existing = db.query(Person).filter(
        Person.telephone == person.telephone,
        Person.user_id == person.user_id
    ).first()

    if existing:
        raise HTTPException(
            status_code=400,
            detail="Ce numéro existe déjà dans vos contacts"
        )

    db_person = Person(
        nom=person.nom,
        prenom=person.prenom,
        telephone=person.telephone,
        user_id=person.user_id
    )

    db.add(db_person)
    db.commit()
    db.refresh(db_person)
    return db_person


@app.get("/personnes/{user_id}", response_model=List[PersonResponse])
def get_persons(user_id: int, db: Session = Depends(get_db)):
    return db.query(Person).filter(Person.user_id == user_id).all()


@app.get("/personnes/search/{user_id}/{query}", response_model=List[PersonResponse])
def search_persons(user_id: int, query: str, db: Session = Depends(get_db)):
    return db.query(Person).filter(
        Person.user_id == user_id,
        (Person.nom.ilike(f"%{query}%")) |
        (Person.prenom.ilike(f"%{query}%")) |
        (Person.telephone.ilike(f"%{query}%"))
    ).all()


@app.get("/personnes/detail/{user_id}/{person_id}", response_model=PersonResponse)
def get_person(user_id: int, person_id: int, db: Session = Depends(get_db)):
    person = db.query(Person).filter(
        Person.id == person_id,
        Person.user_id == user_id
    ).first()

    if not person:
        raise HTTPException(status_code=404, detail="Personne non trouvée")

    return person


@app.put("/personnes/{user_id}/{person_id}", response_model=PersonResponse)
def update_person(
        user_id: int,
        person_id: int,
        person: PersonCreate,
        db: Session = Depends(get_db)
):
    db_person = db.query(Person).filter(
        Person.id == person_id,
        Person.user_id == user_id
    ).first()

    if not db_person:
        raise HTTPException(status_code=404, detail="Personne non trouvée")

    existing = db.query(Person).filter(
        Person.telephone == person.telephone,
        Person.user_id == user_id,
        Person.id != person_id
    ).first()

    if existing:
        raise HTTPException(
            status_code=400,
            detail="Ce numéro existe déjà"
        )

    db_person.nom = person.nom
    db_person.prenom = person.prenom
    db_person.telephone = person.telephone

    db.commit()
    db.refresh(db_person)
    return db_person


@app.delete("/personnes/{user_id}/{person_id}")
def delete_person(user_id: int, person_id: int, db: Session = Depends(get_db)):
    person = db.query(Person).filter(
        Person.id == person_id,
        Person.user_id == user_id
    ).first()

    if not person:
        raise HTTPException(status_code=404, detail="Personne non trouvée")

    db.delete(person)
    db.commit()
    return {"message": "Personne supprimée avec succès"}

# ================== AUTH ROUTES ==================

@app.post("/auth/register", response_model=UserResponse)
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.numero == user.numero).first()
    if existing:
        raise HTTPException(status_code=400, detail="Ce numéro existe déjà")

    db_user = User(
        nom=user.nom.lower(),
        prenom=user.prenom.lower(),
        numero=user.numero,
        mot_de_passe=hash_password(user.mot_de_passe),
    )

    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


@app.post("/auth/login", response_model=UserResponse)
def login_user(credentials: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(
        User.numero == credentials.numero
    ).first()

    if not user or not verify_password(
            credentials.mot_de_passe,
            user.mot_de_passe
    ):
        raise HTTPException(
            status_code=401,
            detail="Numéro ou mot de passe incorrect"
        )

    return user

# ================== MAIN ==================

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )
