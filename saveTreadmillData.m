function [cmDisplacement,timeInterval,cmPerSecond,Wheel] = saveTreadmillData(dateAndTime,countall,timeall,odorPulseAll)

    % foam roller perimeter in centimeters
    perimeter = 47;

    % rotary encoder resolution
    % how many counts it takes to rotate full 360 degrees
    countsPerRevolution = 600;
    
    % Calculate treadmill velocity from wheel position
    % 600 counts correspond to full 360 degrees, i.e. full perimeter of foam
    % roller, which is 47 cm.
    cmDisplacement = diff(countall*(perimeter/countsPerRevolution));

    % calculate the interCountInterval - do not trust whatever was set up
    % as user input because MATLAB is not trustworthy!
    timeInterval = diff(timeall);
    cmPerSecond = cmDisplacement./timeInterval;
    
    % Store data
    Wheel(:,5) = odorPulseAll(1:end-1);
    Wheel(:,4) = cmPerSecond;
    Wheel(:,3) = cmDisplacement;
    Wheel(:,2) = diff(countall);
    Wheel(:,1) = timeall(1:end-1);

    % save data
    file = input('Filename: ','s');
    f1 = sprintf('%s_tread.csv',file);
    csvwrite(f1,Wheel);

    % plot velocity data
    figure('Name', strcat(dateAndTime, '__Velocity__Pos_forward__Neg_backward'))
    plot(Wheel(:,1),Wheel(:,2))
    ylabel('Velocity (cm/s)');
    xlabel('Time (s)')

    % plot odor pulse data
    figure('Name', strcat(dateAndTime, '__Odor'))
    plot(Wheel(:,1),Wheel(:,5))
    ylabel('Odor pulse (V)');
    xlabel('Time (s)')

end
