import 'package:flutter/foundation.dart';

Map<String, String> config = {
  'backend_url': kDebugMode
      // 'backend_url': false
      // ? 'http://localhost:5482'
      ? 'http://10.0.2.2:5482'
      : 'https://stash.tortitas.eu',
  'stripe_public_key':
      'pk_test_51POOCGJ71FWx9p48UOMqI0GeyA7tHcMsUlDDwF1oVzyxWsa8x8ExhLeN6GM80mZisDd2TJ1yJeKuQ8AvSjZmL6c7004CsjKJ3H',
};
