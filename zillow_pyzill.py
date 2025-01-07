import pyzill
import json
import csv 
import pandas as pd

#pagination is for the list that you see at the right when searching
#you don't need to iterate over all the pages because zillow sends the whole 
# data on mapresults at once on the first page
#however the maximum result zillow returns is 500, so if mapResults is 500
#try playing with the zoom or moving the coordinates, pagination won't help 
# because you will always get at maximum 500 results
pagination = 1

coordinates = [
    (34.04822022478224, -118.54380808534304),
    (33.94286974516112, -118.40348813649958),
    (34.09105382290195, -118.36531820536337),
    (34.07427520976152, -118.3594909268181),
]
ne_lat = max([coord[0] for coord in coordinates])
ne_long = max([coord[1] for coord in coordinates])
sw_lat = min([coord[0] for coord in coordinates])
sw_long = min([coord[1] for coord in coordinates])
print(f"northeast point: ({ne_lat}, {ne_long})")
print(f"southwest point: (f{sw_lat}, {sw_long})")

results_sale = pyzill.for_sale(
    pagination, 
    search_value="",
    min_beds=None, max_beds=None,
    min_bathrooms=None, max_bathrooms=None,
    min_price=None, max_price=10000000,
    ne_lat=ne_lat, ne_long=ne_long, sw_lat=sw_lat, sw_long=sw_long,
    zoom_value=10,
)
for k, v in results_sale.items():
    if isinstance(v, list):
        print(k, len(v))
    else:
        print(k, v)
map_results = results_sale['mapResults']
print(f"found {len(map_results)} results")

with open("./jsondata_sale.json", "w") as f:    
    f.write(json.dumps(results_sale, indent=4))

with open("./map_results.json", "w") as f:
    f.write(json.dumps(map_results, indent=4))

fieldnames = [
    "type",
    "address",
    "zipcode",
    "price",
    "area",
    "beds",
    "baths",
    "detailUrl",
    "listedBy",
    "isBuilding",
    "flexFieldText",
    "daysOnZillow",
    "isFavorite",
    "listingType",
]
print(fieldnames)

cols_to_consolidate = [
    "area",
    "beds",
    "baths",
]

cols_to_rename = {
    "statusText": "type",
    "info6String": "listedBy",
    "timeOnZillow": "daysOnZillow",
}

def get_zipcode(address):
    zip = address.split(" ")[-1]
    return zip if zip.isnumeric() else None

df = pd.DataFrame(map_results)
df["zipcode"] = df["address"].apply(get_zipcode)
df["timeOnZillow"] = (df.timeOnZillow / 1000 / 60 / 60 / 24).astype(int)
print(df.columns)
for col in cols_to_consolidate:
    df[col].fillna(df[f"min{col.title()}"], inplace=True)
df = df.rename(columns=cols_to_rename)[fieldnames]

print(df.shape)
print(df.head())
print(df.iloc[0,])
print(df.dtypes)

df.to_csv("./map_results.csv")


# with open("./map_results.csv", "w") as f:
#     writer = csv.DictWriter(
#         f, 
#         fieldnames=fieldnames
#     )
#     writer.writeheader()
#     writer.writerows(map_results)
