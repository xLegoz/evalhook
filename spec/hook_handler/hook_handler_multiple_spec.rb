require "rubygems"
require "evalhook"

describe EvalHook::HookHandler, "hook handler hooks" do


  it "should instance empty MultiHookHandler" do
    EvalHook::MultiHookHandler.new.should be_an_instance_of(EvalHook::MultiHookHandler)
  end

  exprlist = ["1+1", "[1,2,3].map{|x| x*2}"]

  exprlist.each do |expr|
    it "should eval expresion '#{expr}' same as eval" do
      mhh = EvalHook::MultiHookHandler.new
      expected = eval(expr)
      mhh.evalhook(expr).should be == expected

    end
  end

  class X
    def foo

    end
  end

  it "should allow method calls" do
    hook_handler = EvalHook::HookHandler.new
    hook_handler.evalhook("X.new.foo").should be X.new.foo
  end

  it "should capture method calls" do
    hook_handler = EvalHook::MultiHookHandler.new

    hook_handler.should_receive(:handle_method).with(X.class,X,:new)
    hook_handler.should_receive(:handle_method).with(X,anything(),:foo)

    hook_handler.evalhook("X.new.foo")
  end

  it "should capture constant assignment" do
    hook_handler = EvalHook::MultiHookHandler.new

    hook_handler.should_receive(:handle_cdecl).with(Object,:TEST_CONSTANT,4)
    hook_handler.evalhook("TEST_CONSTANT = 4")

  end

  it "should capture global assignment" do
    hook_handler = EvalHook::MultiHookHandler.new

    hook_handler.should_receive(:handle_gasgn).with(:$test_global_variable,4)
    hook_handler.evalhook("$test_global_variable = 4")

  end

  it "should add nested hook handlers" do
    hook_handler = EvalHook::MultiHookHandler.new

    hook_handler.add EvalHook::HookHandler.new
    hook_handler.add EvalHook::HookHandler.new
  end

  it "nested hook handler should capture method calls" do
    hook_handler = EvalHook::MultiHookHandler.new

    nested_handler = EvalHook::HookHandler.new
    hook_handler.add nested_handler

    hook_handler.should_receive(:handle_method).with(X.class,X,:new)
    nested_handler.should_receive(:handle_method).with(X.class,X,:new)
    hook_handler.should_receive(:handle_method).with(X,anything(),:foo)
    nested_handler.should_receive(:handle_method).with(X,anything(),:foo)

    hook_handler.evalhook("X.new.foo")
  end

  it "nested hook handler should capture constant assignment" do
    hook_handler = EvalHook::MultiHookHandler.new

    nested_handler = EvalHook::HookHandler.new
    hook_handler.add nested_handler

    hook_handler.should_receive(:handle_cdecl).with(Object,:TEST_CONSTANT,4)
    nested_handler.should_receive(:handle_cdecl).with(Object,:TEST_CONSTANT,4)

    hook_handler.evalhook("TEST_CONSTANT = 4")
  end

  it "nested hook handler should capture global assignment" do
    hook_handler = EvalHook::MultiHookHandler.new

    nested_handler = EvalHook::HookHandler.new
    hook_handler.add nested_handler

    hook_handler.should_receive(:handle_gasgn).with(:$test_global_variable,4)
    nested_handler.should_receive(:handle_gasgn).with(:$test_global_variable,4)

    hook_handler.evalhook("$test_global_variable = 4")
  end

end