# Parcels Releases

## 0.0.2,

* Fixed an issue where having a `.rb` file in your `views` directory that didn't define a widget class, but rather a
  module (presumably a "helper-like" module of view methods), would cause asset compilation to fail.
