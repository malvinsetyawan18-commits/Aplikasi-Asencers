from sqlalchemy import (
    create_engine,
    Column,
    Integer,
    String,
    Float
)

from sqlalchemy.ext.declarative import (
    declarative_base
)

from sqlalchemy.orm import (
    sessionmaker
)

from config import DATABASE_URL

engine = create_engine(
    DATABASE_URL
)

SessionLocal = sessionmaker(

    autocommit=False,

    autoflush=False,

    bind=engine
)

Base = declarative_base()

class Monitoring(Base):

    __tablename__ = "monitoring"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    sensor_label = Column(
        String
    )

    visual_label = Column(
        String
    )

    final_status = Column(
        String
    )

    confidence = Column(
        Float
    )

Base.metadata.create_all(
    bind=engine
)

def save_monitoring(result):

    db = SessionLocal()

    data = Monitoring(

        sensor_label=result[
            "sensor_result"
        ]["label"],

        visual_label=str(
            result["visual_results"]
        ),

        final_status=result[
            "fusion_result"
        ]["status"],

        confidence=result[
            "sensor_result"
        ]["confidence"]
    )

    db.add(data)

    db.commit()

    db.close()

def get_db():

    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()