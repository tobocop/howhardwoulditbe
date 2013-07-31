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

  describe('.topLevelDomain', function () {
    it('returns plink.dev when passed www.plink.dev', function () {
      expect(Plink.topLevelDomain('www.plink.dev')).toEqual('plink.dev')
    })

    it('returns plink.dev when passed plink.dev', function () {
      expect(Plink.topLevelDomain('plink.dev')).toEqual('plink.dev')
    })

    it('returns plink.dev when passed memolink.plink.dev', function () {
      expect(Plink.topLevelDomain('memolink.plink.dev')).toEqual('plink.dev')
    })

    it('returns plink.dev when passed www.memolink.plink.dev', function () {
      expect(Plink.topLevelDomain('www.memolink.plink.dev')).toEqual('plink.dev')
    })

    it('returns localhost when passed localhost', function () {
      expect(Plink.topLevelDomain('localhost')).toEqual('localhost')
    })

  })


});
