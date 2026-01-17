from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import bcrypt
from database import engine, get_db
from models import Base, Person, PersonCreate, PersonResponse, User, UserCreate, UserLogin, UserResponse

# Password hashing functions
def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Contact API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/personnes", response_model=PersonResponse)
def create_person(person: PersonCreate, db: Session = Depends(get_db)):
    # Check if phone number exists for this user
    db_person = db.query(Person).filter(
        Person.telephone == person.telephone,
        Person.user_id == person.user_id
    ).first()
    if db_person:
        raise HTTPException(status_code=400, detail="Ce numéro de téléphone existe déjà dans vos contacts")
    
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
    persons = db.query(Person).filter(Person.user_id == user_id).all()
    return persons

@app.get("/personnes/search/{user_id}/{query}", response_model=List[PersonResponse])
def search_persons(user_id: int, query: str, db: Session = Depends(get_db)):
    query_lower = query.lower()
    persons = db.query(Person).filter(
        Person.user_id == user_id,
        (Person.nom.ilike(f"%{query_lower}%")) |
        (Person.prenom.ilike(f"%{query_lower}%")) |
        (Person.telephone.ilike(f"%{query_lower}%"))
    ).all()
    return persons

@app.get("/personnes/detail/{user_id}/{person_id}", response_model=PersonResponse)
def get_person(user_id: int, person_id: int, db: Session = Depends(get_db)):
    person = db.query(Person).filter(
        Person.id == person_id,
        Person.user_id == user_id
    ).first()
    if person is None:
        raise HTTPException(status_code=404, detail="Personne non trouvée")
    return person

@app.delete("/personnes/{user_id}/{person_id}")
def delete_person(user_id: int, person_id: int, db: Session = Depends(get_db)):
    person = db.query(Person).filter(
        Person.id == person_id,
        Person.user_id == user_id
    ).first()
    if person is None:
        raise HTTPException(status_code=404, detail="Personne non trouvée")
    
    db.delete(person)
    db.commit()
    return {"message": "Personne supprimée avec succès"}

@app.put("/personnes/{user_id}/{person_id}", response_model=PersonResponse)
def update_person(user_id: int, person_id: int, person: PersonCreate, db: Session = Depends(get_db)):
    db_person = db.query(Person).filter(
        Person.id == person_id,
        Person.user_id == user_id
    ).first()
    if db_person is None:
        raise HTTPException(status_code=404, detail="Personne non trouvée")
    
    # Vérifier si le nouveau numéro existe déjà pour une autre personne de cet utilisateur
    existing = db.query(Person).filter(
        Person.telephone == person.telephone,
        Person.user_id == user_id,
        Person.id != person_id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Ce numéro de téléphone existe déjà dans vos contacts")
    
    db_person.nom = person.nom
    db_person.prenom = person.prenom
    db_person.telephone = person.telephone
    
    db.commit()
    db.refresh(db_person)
    return db_person


#######################""#####""
@app.post("/auth/register", response_model=UserResponse)
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.numero == user.numero).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Ce numéro existe déjà")
    
    # Hash the password before storing
    hashed_password = hash_password(user.mot_de_passe)
    
    db_user = User(
        nom=user.nom.lower(),
        prenom=user.prenom.lower(),
        numero=user.numero,
        mot_de_passe=hashed_password
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@app.post("/auth/login", response_model=UserResponse)
def login_user(credentials: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.numero == credentials.numero).first()
    
    if user is None:
        raise HTTPException(status_code=401, detail="Numéro ou mot de passe incorrect")
    
    # Verify password using hash
    if not verify_password(credentials.mot_de_passe, user.mot_de_passe):
        raise HTTPException(status_code=401, detail="Numéro ou mot de passe incorrect")
    
    return user




if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)