import yaml

from my_project import create_app

with open("config/app.yml", encoding="utf-8") as f:
    config = yaml.safe_load(f)

app = create_app(config)

if __name__ == "__main__":
    app.run(port=config["flask"]["port"], debug=config["flask"]["debug"])
