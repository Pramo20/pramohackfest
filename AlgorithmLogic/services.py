import requests
from typing import List
from dotenv import load_dotenv
import os
import mysql.connector
from chromadb import Client
from chromadb.config import Settings
from chromadb.api import Collection
from pprint import pprint
load_dotenv()


class DatabaseObject:
    def __init__(self) -> None:
        self.connection = mysql.connector.connect(
            host=os.getenv("HOST"),
            user=os.getenv("UNAME"),
            password=os.getenv("PASSWORD"),
            database=os.getenv("DATABASE"),
        )
        self.cursor = self.connection.cursor()

    def insertrequest(
        self,
        requestid: str,
        resourceid: str,
        clusterid: str,
        username: str,
        quantity: int,
        newlat: float,
        newlon: float,
    ):
        # check if clusterid is present in the cluster database
        # if not present, insert it

        query = f"SELECT * FROM clusters WHERE cluster_id='{clusterid}'"
        self.cursor.execute(query)
        result = self.cursor.fetchall()
        if not result:
            self.createcluster(clusterid, 0, 0)

        self.updateclustercentroid(clusterid, newlat, newlon)

        query = f"INSERT INTO requests (request_id, resource_id, cluster_id, username, quantity) VALUES ('{requestid}', '{resourceid}', '{clusterid}', '{username}', {quantity})"
        self.cursor.execute(query)
        self.connection.commit()

    def updaterequestquantity(self, requestid: str, quantity: int):
        query = (
            f"UPDATE requests SET quantity={quantity} WHERE request_id='{requestid}'"
        )
        self.cursor.execute(query)
        self.connection.commit()

    def removerequest(self, requestid: str):
        query = f"DELETE FROM requests WHERE request_id='{requestid}'"
        self.cursor.execute(query)
        self.connection.commit()

    def createcluster(self, clusterid: str, lat: float, lon: float):
        query = f"INSERT INTO clusters (cluster_id, latitude, longitude) VALUES ('{clusterid}', {lat}, {lon})"
        self.cursor.execute(query)
        self.connection.commit()

    def updateclustercentroid(self, clusterid, newlat, newlon):
        query = f"UPDATE clusters SET latitude = {newlat}, longitude = {newlon} WHERE id = {clusterid}"
        try:
            for result in self.connection.cmd_query_iter(query):
                pass  # Iterate through results to ensure all queries are executed
            self.connection.commit()
        except mysql.connector.Error as err:
            print(f"Error: {err}")
            self.connection.rollback()

    def removecluster(self, clusterid: str):
        query = f"DELETE FROM clusters WHERE cluster_id='{clusterid}'"
        self.cursor.execute(query)
        self.connection.commit()

    def insertresource(self, resourceid: str, resourcename: str, resourcetype: str):
        query = f"INSERT INTO resources (resource_id, resource_name, resource_type) VALUES ('{resourceid}', '{resourcename}', '{resourcetype}')"
        self.cursor.execute(query)
        self.connection.commit()

    def removeresource(self, resourceid: str):
        query = f"DELETE FROM resources WHERE resource_id='{resourceid}'"
        self.cursor.execute(query)
        self.connection.commit()
    
    def insertpath(self, pathid: str, pathobject: str):
        query = f"INSERT INTO pathstore (path_id, pathjson) VALUES ('{pathid}', \"{pathobject}\")"
        self.cursor.execute(query)
        self.connection.commit()
    
    def removepath(self, pathid: str):
        query = f"DELETE FROM pathstore WHERE path_id='{pathid}'"
        self.cursor.execute(query)
        self.connection.commit()
    
    def truncatepath(self):
        query = f"TRUNCATE TABLE pathstore"
        self.cursor.execute(query)
        self.connection.commit()


class GoogleAPI:
    def __init__(self):
        self.api_key = os.getenv("GOOGLE_API_KEY")

    def get_distance_matrix(
        self, listoforigins: List[List[float]], listofdestinations: List[List[float]]
    ):
        endpoint = "https://maps.googleapis.com/maps/api/distancematrix/json"

        origins = "|".join([",".join(map(str, origin)) for origin in listoforigins])
        destinations = "|".join(
            [",".join(map(str, destination)) for destination in listofdestinations]
        )

        params = {"origins": origins, "destinations": destinations, "key": self.api_key}

        response = requests.get(endpoint, params=params)

        if response.status_code != 200:
            raise Exception(f"Error making request: {response.status_code}")

        distance_matrix = response.json()

        if "rows" not in distance_matrix or not distance_matrix["rows"]:
            raise Exception("No rows found in response")

        return distance_matrix

    def returndistancebetweentwopoints(
        self, origin: List[float], destination: List[float]
    ):
        endpoint = "https://maps.googleapis.com/maps/api/distancematrix/json"

        params = {
            "origins": f"{origin[0]},{origin[1]}",
            "destinations": f"{destination[0]},{destination[1]}",
            "key": self.api_key,
        }

        response = requests.get(endpoint, params=params)

        if response.status_code != 200:
            raise Exception(f"Error making request: {response.status_code}")

        distance_matrix = response.json()

        output = {
            "distance": distance_matrix["rows"][0]["elements"][0]["distance"]["text"],
            "duration": distance_matrix["rows"][0]["elements"][0]["duration"]["text"],
        }

        return output

    def geocodecoordinatestoaddress(self, coordinatelist:List[float]):
        endpoint = "https://maps.googleapis.com/maps/api/geocode/json"
        print("Attempting to geocode coordinates", coordinatelist)

        params = {
            "key": self.api_key,
            "latlng": f"{coordinatelist[0]},{coordinatelist[1]}",
        }

        response = requests.get(endpoint, params=params)
        if response.status_code != 200:
            raise Exception(f"Error making request: {response.status_code}")

        return response.json()['results'][0]['formatted_address'][:26]

class ChromaDBAgent:
    def __init__(self) -> None:
        self.client = Client(Settings())
        self.collection_name = "path_objects"
        if self.collection_name not in self.client.list_collections():
            self.collection = self.client.create_collection(self.collection_name)
        else:
            self.collection = self.client.get_collection(self.collection_name)
    
    def insertpathobject(self, pathobjectid: str, coordinates):
        vectorobject = {
            "id": pathobjectid,
            "vector": coordinates
        }
        
        self.collection.upsert(vectorobject["id"], vectorobject["vector"])
    
    def getnearestneighbors(self, coordinates, kval=5):
        return self.collection.query(coordinates, n_results=kval)['ids']

    def clearindex(self):
        self.client.delete_collection(self.collection_name)
        self.collection = self.client.create_collection(self.collection_name)
    
    # select and display all the vectors in the collection
    def getallvectors(self):
        return self.collection.get()['ids']
    
    def numberofvectors(self):
        return len(self.collection.get()['ids'])

    def whatallcollectionhas(self):
        return dir(self.collection)

    def whatallclienthas(self):
        return dir(self.client)
