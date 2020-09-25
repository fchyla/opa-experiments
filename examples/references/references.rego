package ref 

sites = [{"name": "prod"}, {"name": "smoke1"}, {"name": "dev"}]

r { sites[_].name == "prod" }