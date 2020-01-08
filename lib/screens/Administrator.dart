import 'package:flutter/material.dart';
import 'package:tourism/screens/GuideApprovals.dart';
import 'package:tourism/screens/admControl.dart';

class Administrator extends StatefulWidget {
  @override
  _AdministratorState createState() => _AdministratorState();
}

class _AdministratorState extends State<Administrator>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Administrator Page"),
        bottom: PreferredSize(
          preferredSize: Size(35,35),
          child: TabBar(
            indicatorWeight: 3,
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            controller: _tabController,
            tabs: <Widget>[
              Tab(text: "Guide Approvals"),
              Tab(text: "Adm Control")
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[GuideApprovals(), admControl()],
      ),
    );
  }
}

/*

 */
