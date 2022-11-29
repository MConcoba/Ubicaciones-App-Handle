import 'package:flutter/material.dart';
import 'package:locations/src/models/package.dart';

class PackageList extends StatefulWidget {
  final List<Package> transactions;
  // final ScrollController listScrollController;
  const PackageList({Key? key, required this.transactions
      // required this.listScrollController
      })
      : super(key: key);

  @override
  State<PackageList> createState() => _PackageListState();
}

class _PackageListState extends State<PackageList> {
  @override
  Widget build(BuildContext context) {
    ScrollController listScrollController = ScrollController();
    // listScrollController.jumpTo(position);
    // final ScrollController listScrollController;

    if (listScrollController.hasClients) {
      final position = listScrollController.position.maxScrollExtent;
      print(position);
      print('position');
      listScrollController.jumpTo(position);
    }

    return Container(
      height: 320,
      padding: EdgeInsets.all(10),
      child: Card(
        child: ListView.builder(
          controller: listScrollController,
          itemBuilder: (ctx, index) {
            if (listScrollController.hasClients) {
              print('asfs');
              final position = listScrollController.position.maxScrollExtent;
              listScrollController.animateTo(
                position,
                duration: Duration(seconds: 1),
                curve: Curves.easeOut,
              );
            }

            return Container(
              // padding: EdgeInsets.only(top: 5),
              child: Center(
                child: Column(
                  children: [
                    // Divider(),
                    ListTile(
                      leading: widget.transactions[index].icono,
                      title: Text(
                        widget.transactions[index].descrition,
                        style: const TextStyle(
                          fontSize: 12,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle:
                          Text(widget.transactions[index].date.toString()),
                    ),
                    Divider(),
                  ],
                ),
              ),
            );
          },
          itemCount: widget.transactions.length,
          padding: EdgeInsets.all(5),
        ),
      ),
    );
  }
}
