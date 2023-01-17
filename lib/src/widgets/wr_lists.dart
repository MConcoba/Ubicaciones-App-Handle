import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../models/package.dart';

class PackageList extends StatefulWidget {
  final List<Package> transactions;
  const PackageList({Key? key, required this.transactions}) : super(key: key);

  @override
  State<PackageList> createState() => _PackageListState();
}

class _PackageListState extends State<PackageList> {
  @override
  Widget build(BuildContext context) {
    ScrollController listScrollController = ScrollController();

    if (listScrollController.hasClients) {
      final position = listScrollController.position.maxScrollExtent;
      listScrollController.jumpTo(position);
    }

    return Container(
      width: 90.w,
      height: 52.h,
      //padding: EdgeInsets.all(10),
      child: Card(
        elevation: 5,
        child: ListView.builder(
          controller: listScrollController,
          itemBuilder: (ctx, index) {
            if (listScrollController.hasClients) {
              final position = listScrollController.position.maxScrollExtent;
              //listScrollController.jumpTo(position)
              listScrollController.animateTo(
                position,
                duration: Duration(seconds: 1),
                curve: Curves.linear,
              );
            }
            return Container(
              child: Center(
                child: Column(
                  children: [
                    ListTile(
                      leading: widget.transactions[index].icono,
                      title: Text(
                        widget.transactions[index].descrition,
                        style: const TextStyle(
                          fontSize: 12,
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
