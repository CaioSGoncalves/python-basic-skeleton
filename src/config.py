from pydantic import Field
from pydantic_settings import BaseSettings

class Settings(BaseSettings):    
        APP_ENV: str = Field(None, description="App environment")
        
        class Config:
                env_file = ".env"
