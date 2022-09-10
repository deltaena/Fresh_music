import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_music_radar/blocs/albums_bloc.dart';
import 'package:fresh_music_radar/models/duration_filters.dart';
import 'package:fresh_music_radar/states/albums_state.dart';

import '../../blocs/events/albums_fetch_event.dart';

class FilterWidget extends StatelessWidget{
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.all(Radius.circular(40)),
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                )
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                    "showing albums released within ",
                    style: TextStyle(fontSize: 16)
                ),
                DropdownButton(
                  items: [
                    DurationFilter.ofMonth1,
                    DurationFilter.ofMonth2,
                    DurationFilter.ofMonth3
                  ].map((DurationFilter filter) =>
                      DropdownMenuItem<Object>(
                          value: filter,
                          child: Text(filter.name)
                      )
                  ).toList(),
                  value: DurationFilter.ofMonth1,
                  onChanged: (filter) {
                    context.read<AlbumsBloc>().add(AlbumsFilterChanged(filter: filter as DurationFilter));

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Filter applied! showing albums from the last ${filter.value} days")));
                  },
                ),
                const Text(
                    " days",
                    style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        }
}












