import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:tdd_tutorial/core/errors/exceptions.dart';
import 'package:tdd_tutorial/core/utils/constants.dart';
import 'package:tdd_tutorial/src/authentication/data/datasources/authentication_remote_data_source.dart';
import 'package:tdd_tutorial/src/authentication/data/models/user_model.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  late http.Client client;
  late AuthenticationRemoteDataSource remoteDataSource;

  setUp(() {
    client = MockClient();
    remoteDataSource = AuthenticationRemoteDataSourceImplementation(client);
    registerFallbackValue(Uri());
  });

  group('createUser', () {
    test(
      'should complete successfully when the status code is 200 or 201',
      () async {
        // Arrange
        when(
          () => client.post(
            any(),
            body: any(named: "body"),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        ).thenAnswer(
          (_) async => http.Response('User created successfully', 201),
        );

        // Act
        final methodCall = remoteDataSource.createUser;

        // Assert
        expect(
          methodCall(
            createdAt: 'createdAt',
            name: 'name',
            avatar: 'avatar',
          ),
          completes,
        );
        verify(
          () => client.post(Uri.https(kBaseUrl, kCreateUserEndpoint),
              body: jsonEncode({
                'createdAt': 'createdAt',
                'name': 'name',
                'avatar': 'avatar',
              }),
              headers: {
                'Content-Type': 'application/json',
              }),
        ).called(1);
        verifyNoMoreInteractions(client);
      },
    );

    test(
      'should throw [APIException] when the status code is not 200 or 201',
      () async {
        // Arrange
        when(
          () => client.post(
            any(),
            body: any(named: "body"),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        ).thenAnswer(
          (_) async => http.Response('Failed to create user', 400),
        );

        // Act
        final methodCall = remoteDataSource.createUser;

        // Assert
        expect(
          () async => methodCall(
            createdAt: 'createdAt',
            name: 'name',
            avatar: 'avatar',
          ),
          throwsA(
            const APIException(
              message: 'Failed to create user',
              statusCode: 400,
            ),
          ),
        );
        verify(
          () => client.post(Uri.https(kBaseUrl, kCreateUserEndpoint),
              body: jsonEncode({
                'createdAt': 'createdAt',
                'name': 'name',
                'avatar': 'avatar',
              }),
              headers: {
                'Content-Type': 'application/json',
              }),
        ).called(1);
        verifyNoMoreInteractions(client);
      },
    );
  });

  group('getUsers', () {
    const tUsers = [
      UserModel.empty(),
    ];

    test(
      'should return [List<User>] when the status code is 200',
      () async {
        // Arrange
        when(() => client.get(any())).thenAnswer(
          (_) async => http.Response(jsonEncode([tUsers.first.toMap()]), 200),
        );

        // Act
        final result = await remoteDataSource.getUsers();

        // Assert
        expect(result, equals(tUsers));
        verify(
          () => client.get(
            Uri.https(kBaseUrl, kGetUsersEndpoint),
          ),
        ).called(1);
        verifyNoMoreInteractions(client);
      },
    );

    test(
      'should throw [APIException] when the status code is not 200',
      () async {
        // Arrange
        const tMessage = 'Server down due to unknown error';

        when(() => client.get(any())).thenAnswer(
          (_) async => http.Response(
            tMessage,
            500,
          ),
        );

        // Act
        final methodCall = remoteDataSource.getUsers;

        // Assert
        expect(
          () => methodCall(),
          throwsA(
            const APIException(
              message: tMessage,
              statusCode: 500,
            ),
          ),
        );
        verify(
          () => client.get(
            Uri.https(kBaseUrl, kGetUsersEndpoint),
          ),
        ).called(1);
        verifyNoMoreInteractions(client);
      },
    );
  });
}
