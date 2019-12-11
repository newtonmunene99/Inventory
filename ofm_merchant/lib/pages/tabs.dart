import 'package:flutter/material.dart';
import './shops.dart';
import './profile.dart';
import './products.dart';
import './sales.dart';
import "./waste.dart";
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';

class TabsPage extends StatefulWidget {
  @override
  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage>
    with SingleTickerProviderStateMixin {
  List<Widget> pages = [
    ShopsPage(),
    ProductsPage(),
    SalesPage(),
    WastePage(),
    ProfilePage(),
  ];
  TabController _tabController;
  int _currentIndex;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: pages.length);
    _currentIndex = 0;
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: pages,
        ),
        bottomNavigationBar: BubbleBottomBar(
          opacity: .2,
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
            _tabController.animateTo(index,
                duration: Duration(milliseconds: 300), curve: Curves.ease);
          },
          elevation: 8,
          hasNotch: false, //new
          hasInk: true, //new, gives a cute ink effect
          items: <BubbleBottomBarItem>[
            BubbleBottomBarItem(
                backgroundColor: Theme.of(context).primaryColor,
                icon: Icon(
                  Icons.store,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.store,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text("Shops")),
            BubbleBottomBarItem(
                backgroundColor: Theme.of(context).primaryColor,
                icon: Icon(
                  Icons.shopping_basket,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.shopping_basket,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text("Products")),
            BubbleBottomBarItem(
                backgroundColor: Theme.of(context).primaryColor,
                icon: Icon(
                  Icons.attach_money,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.attach_money,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text("Sales")),
            BubbleBottomBarItem(
                backgroundColor: Theme.of(context).primaryColor,
                icon: Icon(
                  Icons.delete_sweep,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.delete_sweep,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text("Waste")),
            BubbleBottomBarItem(
                backgroundColor: Theme.of(context).primaryColor,
                icon: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                activeIcon: Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text("Profile")),
          ],
        ),
        // bottomNavigationBar: TabBar(
        //   tabs: <Widget>[
        //     Tab(
        //       text: "Home",
        //     ),
        //     Tab(
        //       text: "Sales",
        //     ),
        //     Tab(
        //       text: "Waste",
        //     ),
        //     Tab(
        //       text: "Products",
        //     ),
        //     Tab(
        //       text: "Profile",
        //     ),
        //   ],
        //   labelColor: Colors.yellow,
        //   unselectedLabelColor: Colors.blue,
        //   indicatorSize: TabBarIndicatorSize.label,
        //   indicatorPadding: EdgeInsets.all(5.0),
        //   indicatorColor: Colors.red,
        // ),
        backgroundColor: Colors.black,
      ),
    );
  }
}
