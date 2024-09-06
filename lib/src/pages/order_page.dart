import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalii Livrare'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nume'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Te rog introdu numele tău';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Adresă'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Te rog introdu adresa de livrare';
                  }
                  return null;
                },
                onSaved: (value) {
                  address = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Număr de telefon'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Te rog introdu numărul de telefon';
                  }
                  return null;
                },
                onSaved: (value) {
                  phoneNumber = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Handle form submission (you can save the details or send them to an API)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Comanda a fost finalizată')),
                    );
                  }
                },
                child: Text('Trimite comanda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
