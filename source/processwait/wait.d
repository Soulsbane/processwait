module processwait.wait;

import std.process;
import core.time;

public import progress.spinner;
import simpletimers.repeating;
// TODO: Fix/Add documentation.
/**
	A simple wrapper around ProcessWait.

	Params:
		args = The application name followed by the arguments to pass to it.

		Returns:
			The same value as $(LINK2 http://dlang.org/phobos/std_process.html#.wait, std.process.wait).
*/
auto waitForApplication(SpinnerType = Spinner)(const string[] args...)
{
	auto process = new ProcessWait!SpinnerType;
	immutable auto exitStatus = process.execute(args);

	return exitStatus;
}

// Available spinners, Spinner(default), PieSpinner, MoonSpinner and LineSpinner.
class ProcessWait(SpinnerType) : RepeatingTimer
{
	this()
	{
		spinner_ = new SpinnerType();
		spinner_.message = { return "Loading "; };
	}

	void setUpdateFrequency(Duration frequency = dur!("msecs")(250))
	{
		frequency_ = frequency;
	}

	/**
		Executes an process that will wait using a progress indicator until the process exits.

		Params:
			args = The args to pass to the process where the first argument is the process name.

		Returns:
			The same value as $(LINK2 http://dlang.org/phobos/std_process.html#.wait, std.process.wait).
	*/
	auto execute(const string[] args...)
	{
		auto pipes = pipeProcess(args);
		start(frequency_);

		immutable auto exitStatus = wait(pipes.pid);
		stop();
		spinner_.finish();

		return exitStatus;
	}

	override void onTimer()
	{
		spinner_.next();
	}
private:
	SpinnerType spinner_;
	Duration frequency_ = dur!("msecs")(250);
}
