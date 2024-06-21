% to use arduino functions, install this add-on:
% matlab.internal.addons.showAddon('ML_ARDUINO');
% to use rotaryEncoder function, also install the RotaryEncoder library
% TO DO: check cm/s calculation --> SOLVED: matlab was not pausing for as
% long as I asked it to; it was pausing for 0.1 s instead of 0.01 s! so a
% better way of calculating velocity is to calculate the difference between
% time-stamps post-hoc.

clear all

%% ARDUINO stuff

% comment out after first run to save time and to avoid issues with
% olfactometer COM port

% % define arduino object - requires arduino add-on
% a = arduino();
% 
% % define inputs of rotary encoder - requires arduino add-on + library
% % "Output A" (white wire) connects to D2.
% % "Output B" (green wire) connects to D3.
% encoder = rotaryEncoder(a,'D2','D3');


%% USER INPUTS

% max duration in seconds (5400 s = 1.5 h)
maxdur = 5400;

% interval between acquiring counts from encoder in seconds 
interCountInterval = 0.01;


%% MAIN CODE

% Wait for user input to start 
sprintf('Press any key to start')
pause

% find today's date and time for naming figure
dateAndTime = string(datetime('now','Format','yyyy-MM-dd_HH-mm-ss'));

% create first entry in columns that will be filled out
timeall=0;
countall=0;
odorPulseAll = 0;

% create and name treadmill figure
livetrack = figure('Name', strcat(dateAndTime, '__Treadmill__Pos_forward__Neg_backward'));
h = animatedline;
ax = gca;

% create stop button
button = figure(2);
x0=1700;
y0=50;
width=200;
height=100;
set(gcf,'position',[x0,y0,width,height])
ButtonHandle = uicontrol('Parent',button,...
    'Style', 'PushButton', ...
    'String', 'Stop recording',...
    'Position',[4 2 192 96],...
    'Callback', 'delete(gcbf)');

% read analog input from olfactometer
% % %  comment out if troubleshooting code without arduino
odorPulse = readVoltage(a,'A5');

% gather data from arduino
% t0 is the timestamp in datetime format at the begining
% % %  comment out if troubleshooting code without arduino
% [count,t0] = readCount(encoder);
% [count,timestamp] = readCount(encoder);
% t = timestamp - t0;

% comment out the 3 lines above and comment in the following lines for
% troubleshooting the code without the arduino connected
count = 1;
t0=0;
timestamp = 1;
t = timestamp - t0;

while t < maxdur
    % check if user pressed button to stop recording
    if ~ishandle(ButtonHandle)
        disp('Recording stopped by user');   
        % ask if user wants to save the data
        str = input('Would you like to save output variables? y/n: ','s');
        if strcmp(str,'y')
            % save the data
            [cmDisplacement,timeInterval,cmPerSecond,Wheel] = saveTreadmillData(dateAndTime,countall,timeall,odorPulseAll);
        end
        % stop the while loop
        break;
    end

    % if user did not end the data collection, continue collecting data
    timeall=cat(1, timeall, t);
    countall=cat(1, countall, count);
    odorPulseAll = cat(1, odorPulseAll, odorPulse);

    % Update treadmill plot
    addpoints(h,t,count-countall(end-1));
    ax.XLim = [0, t+5];
    ax.YLim = [-1000, 1000];
    ylabel('Counts in 10 to 1000 ms');
    xlabel('Time (s)')
    drawnow

    % pause the drawing for interCountInterval - this sets up max
    % acquisition rate. If interCountInterval = 0.01, acqusition is 100 Hz
    pause(interCountInterval)

    % update time
    % % %  comment out for troubleshooting code
    % [count,timestamp] = readCount(encoder);
    % t = timestamp - t0;
    % odorPulse = readVoltage(a,'A5');

    % lines for troubleshooting code without the arduino - comment out the
    % 3 lines above and comment in the 3 lines below
    count = count + 1;
    timestamp = timestamp + 1;
    t = timestamp - t0;    
end


% If button was not pressed yet, ask user about saving the data
if ~ishandle(ButtonHandle)
    disp('done')
else
    str = input('Would you like to save output variables? y/n: ','s');
    if strcmp(str,'y')
        [cmDisplacement,timeInterval,cmPerSecond,Wheel] = saveTreadmillData(dateAndTime,countall,timeall,odorPulseAll);
        close(button);
        close(livetrack);
    else
    end
end