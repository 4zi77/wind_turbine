clear all
%%
%data that was given by doc or prof
vr = 20; %rotating speed in rpm
fr = vr / 60; %shaft rotating frequency

%init
Date = ["2014-04-01" "2014-04-28"];
color_p = ['r', 'b', 'g'];
%f_meca = [{'vib1'} {'vib2'} {'vib3'} {'lss'} {'hss'}];
f_meca = [{'lss'}];
nFields = length(f_meca);
figs = figure('Name', 'All spectra')

for p = 1:length(Date) %loop on files (dates)
    date = Date(p);
    dataDir = 'Z:\4A\WindTurbineMonitoring\data\'; %uigetdir; %gets directory
    allFiles = dir(fullfile(dataDir, date + "*"));
    old_data = load(strcat(dataDir, allFiles(1).name));
    %merge fields to create one large data srtuture
    for i = 2:length(allFiles)
        data = load(strcat(dataDir, allFiles(i).name));
        f = fieldnames(old_data);
        for j = 1:length(f)
            data.(f{j}) = old_data.(f{j});
        end
        old_data = data;
    end

    % First analyse mecanical data: vib123 and lss and hss
    data_meca = [];
    for j = 1:nFields
        data_meca.(f_meca{j}) = data.(f_meca{j});
    end

    figt = figure('Name', 'Figure for date ' + Date(p))
    
    for k = 1:nFields %loop on variables (fields) to plot
        figure(figt)
        subplot(1,nFields,k)
        cur_data = data_meca.(f_meca{k});
        cur_raw = cur_data.rawData;
        fs = cur_data.fs;
        ts = 1/fs;
        t0 = cur_data.timeStamp;
        nsamples = length(cur_raw);

        time_axis = linspace(t0, t0 + ts * nsamples, nsamples);
        plot(time_axis, cur_raw)
        title(cur_data.sensorName + " / " + cur_data.unit)
        xlabel("Time / s")
        ylabel(cur_data.unit)

        figure(figs)
        subplot(1,nFields,k); hold on;
        T = time_axis(end)-time_axis(1);
        freq_axis = linspace(0, 1/T * fs/2, nsamples/2);
        spectr = abs(fft(cur_raw)); %matlab functions pour spectre direct + périodogramme moyenné (pwelch) plus adapté car bruité
        stem(freq_axis(2:end), spectr(2:(nsamples/2)), color_p(p))
        title("Module spectrum of " + cur_data.sensorName)
        xlabel("Frequency / Hz")
        grid on;
    end

end
