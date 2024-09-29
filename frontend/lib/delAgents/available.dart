import 'package:flutter/material.dart';
import 'package:frontend/delAgents/MapView.dart';
import 'package:frontend/utilities/apiFunctions.dart';

class DeliveryDetails {
  final String fromLoc;
  final double distanceFromDelAgent;

  const DeliveryDetails({
    required this.fromLoc,
    required this.distanceFromDelAgent,
  });
}

class DeliveryDetailsWidget extends StatelessWidget {
  final DeliveryDetails deliveryDetails;
  final int pathIndex;

  const DeliveryDetailsWidget({
    Key? key,
    required this.deliveryDetails,
    required this.pathIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(13),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 10, 7, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 25,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          deliveryDetails.fromLoc,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.directions,
                        color: Colors.blue,
                        size: 25,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Pickup within ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${deliveryDetails.distanceFromDelAgent} km',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapView(pathIndex: pathIndex),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: Color.fromARGB(255, 0, 225, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                minimumSize: Size(30, 35),
              ),
              child: Text(
                'View',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Available extends StatefulWidget {
  const Available({Key? key}) : super(key: key);

  @override
  State<Available> createState() => _AvailableState();
}

class _AvailableState extends State<Available> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Available Routes',
          style: TextStyle(
            letterSpacing: 1.5,
            color: Colors.white70,
          ),
        ),
        backgroundColor: Colors.grey[850],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5),
        child: FutureBuilder<List<List<String>>>(
          future: loadPathsNames(),
          builder: (BuildContext context,
              AsyncSnapshot<List<List<String>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data available'));
            } else {
              List<DeliveryDetails> deliveryDetailsList = snapshot.data!
                  .map((path) => DeliveryDetails(
                      fromLoc: path[0],
                      distanceFromDelAgent:
                          double.parse(path[1].split(' ')[0])))
                  .toList();
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ...deliveryDetailsList
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 2),
                            child: DeliveryDetailsWidget(
                              deliveryDetails: entry.value,
                              pathIndex: entry.key, // Pass the index
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
