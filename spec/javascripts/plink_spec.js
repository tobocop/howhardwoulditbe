describe('Plink', function () {
  describe('.conditionalCallback', function () {
    it('calls the callback when given true', function () {
      callback = jasmine.createSpy();

      Plink.conditionalCallback(true, callback);

      expect(callback).toHaveBeenCalled();
    });

    it('does not call the callback when false', function () {
      callback = jasmine.createSpy();

      Plink.conditionalCallback(false, callback);

      expect(callback).not.toHaveBeenCalled();
    });
  })
});
