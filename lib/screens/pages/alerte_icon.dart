import 'package:flutter/material.dart';
import '../../services/alertes_service.dart';
import '../pages/alerte_page.dart';

class AlerteIcon extends StatefulWidget {
  @override
  _AlerteIconState createState() => _AlerteIconState();
}

class _AlerteIconState extends State<AlerteIcon> {
  final AlertesService _alertesService = AlertesService();
  int _nonTraiteesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAlertes();
  }

  Future<void> _loadAlertes() async {
    final alertes = await _alertesService.getAllAlertes();
    setState(() {
      _nonTraiteesCount = alertes.where((a) => a['traitee'] == false).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications, color: Color.fromARGB(255, 67, 1, 39)),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AlertePage()),
            );
            _loadAlertes(); // Reload les alertes après retour
          },
        ),
        if (_nonTraiteesCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$_nonTraiteesCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
