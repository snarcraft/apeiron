/// Laravel-style service provider: register (wire), boot
/// (activate), dispose (teardown). register() must never resolve
/// other providers' services; boot() may.
abstract class ServiceProvider {
  Future<void> register();

  Future<void> boot();

  Future<void> dispose();
}
