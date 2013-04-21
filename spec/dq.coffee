describe 'dq', =>
  global = this
  output = null
  options = null

  queue = []
  modules = {}

  beforeEach =>
    global._spy = sinon.spy()
    modules = {
      say: (something) =>
        output.push something
      spy: sinon.spy()
    }

    queue = []
    output = []
    options = {
      q: queue,
      modules: modules
    }

  it 'should process queued calls to global methods', =>
    queue.push(['_spy'])
    dq(options)
    expect(_spy).to.have.been.calledOnce

  it 'should process queued calls to module methods', =>
    queue.push(['spy'])
    dq(options)
    expect(modules.spy).to.have.been.calledOnce

  it 'should prefer module methods over global ones', =>
    queue.push(['_spy'])
    modules._spy = modules.spy
    dq(options)
    expect(modules._spy).to.have.been.calledOnce
    expect(_spy).not.to.have.been.called

  it 'should send arguments when making calls', =>
    queue.push(['spy', 1, "two", { three: 3 }])
    dq(options)
    expect(modules.spy).to.have.been.calledWith(1, "two", { three: 3 })

  it 'should make calls in the order queued', =>
    queue.push(
      ['say', 1],
      ['say', 2],
      ['say', 3]
    )
    dq(options)
    expect(output).to.eql([1, 2, 3])

  it 'should throw an error when encountering undeclared methods', =>
    fn = ->
      dq(options)
    queue.push(['bork'])
    expect(fn).to.throw('No such method: bork')

  it 'should process globally declared _q query array by default', =>
    global._q = [['_spy']]
    dq()
    expect(_spy).to.have.been.calledOnce