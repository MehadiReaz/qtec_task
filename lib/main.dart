import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_bloc.dart';
import 'package:qtec_task/features/products/presentation/bloc/product_events.dart';

import 'features/products/presentation/pages/product/product_list.dart';
import 'injection_container.dart';

void main() async {
  await setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductBloc>(
        create: (context) => getIt()..add(const GetProductsEvent()),
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Qtec Task',
            home: ProductList()));
  }
}
