import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/responsive.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/custom_button.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<HomeViewModel>(
            builder: (context, viewModel, child) {
              return Text(viewModel.title);
            },
          ),
        ),
        body: SafeArea(
          child: ResponsiveCenter(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Consumer<HomeViewModel>(
                    builder: (context, viewModel, child) {
                      return Text(
                        viewModel.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    text: 'Update Title',
                    onPressed: () {
                      Provider.of<HomeViewModel>(
                        context,
                        listen: false,
                      ).updateTitle('Updated Title');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
