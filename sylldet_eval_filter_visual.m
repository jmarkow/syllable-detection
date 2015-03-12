function sylldet_eval_filter_visual(COEFFS,TRIM_IDXS,FILT_DATA,SOUND_DATA,STATS,FS)
%
%
%
%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% parameters

rms_tau=.015;
trial=5;

[nsamples,ntrials]=size(SOUND_DATA);

trials=100:ntrials;

timevec_song=[1:nsamples]/FS;
order=length(COEFFS);
timevec=[1:order]/FS;

% visualize the filter

trim_idxs_t=(order-TRIM_IDXS)/FS;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% impulse response

figure();

[s,f,t]=zftftb_pretty_sonogram(COEFFS(end:-1:1),FS,'zeropad',0,'len',100,'overlap',99,'clipping',[-3 1],'norm_amp',1);

ax(1)=subplot(2,1,1);
imagesc(t,f/1e3,s);axis xy;
title('Time-reversed impulse response');
ylabel('Fs (kHz)');

% plot the trim indices

hold on;
ylimits=ylim();
plot(repmat(trim_idxs_t(:)',[2 1]),repmat(ylimits(:),[ 1 2]),'y--','linewidth',2);
linkaxes(ax,'x');
xlim([timevec(1) timevec(end)]);

ax(2)=subplot(2,1,2);
plot(timevec,COEFFS(end:-1:1));
box off;
ylabel('Amp.');
xlabel('Time (s)');
hold on;
ylimits=ylim();
plot(repmat(trim_idxs_t(:)',[2 1]),repmat(ylimits(:),[ 1 2]),'r--','linewidth',2);

linkaxes(ax,'x');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% trigger points

% plot sample spectrogram, microphone rms,trigger points 

[b,a]=ellip(4,.2,40,[1e3 7e3]/(FS/2),'bandpass');
filt_data=filtfilt(b,a,double(SOUND_DATA));
rms_smps=round(rms_tau*FS);
rms_filt=ones(rms_smps,1)/rms_smps;

rms=sqrt(filter(rms_filt,1,filt_data.^2));

[s,f,t]=zftftb_pretty_sonogram(SOUND_DATA(:,trial),FS,'zeropad',0,'clipping',[-2 1]);
[~,loc]=max(STATS.acc);
threshold=STATS.thresholds(loc);

hit_mat=filter(COEFFS(TRIM_IDXS(1):TRIM_IDXS(2)),1,SOUND_DATA);
[smps,trials]=find(hit_mat.^2>threshold);

uniq_trials=unique(trials);
new_smps=zeros(1,length(uniq_trials));

for i=1:length(uniq_trials)
	trial_smps=smps(trials==uniq_trials(i));
	new_smps(i)=min(trial_smps);
end

figure();ax(1)=subplot(4,1,1);
imagesc(t,f/1e3,s);axis xy;
ylabel('Fs (kHz)');
title('Triggers at optimal threshold');
freezeColors;

ax(2)=subplot(4,1,2:4);
imagesc(timevec_song,[],zscore(rms)');
colormap(gray);
ylabel('Trial');
xlabel('Time (s)');
freezeColors;
hold on;
scatter(timevec_song(new_smps),uniq_trials,'r.');

linkaxes(ax,'x');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% roc curve

nthresh=length(STATS.thresholds);
fpr=zeros(1,nthresh);
tpr=zeros(1,nthresh);

for i=1:length(STATS.thresholds)
	p=sum(STATS.conf_mat(1,:,i),2);
	n=sum(STATS.conf_mat(2,:,i),2);
	fpr(i)=STATS.conf_mat(2,1,i)/p;
	tpr(i)=STATS.conf_mat(1,1,i)/n;
end

figure();
plot(fpr,tpr);
box off;
ylabel('Hit rate');
xlabel('False alarm rate');


figure();ax(1)=subplot(4,1,1);
imagesc(t,f/1e3,s);axis xy;
ylabel('Fs (kHz)');
title('Squared filter output');
freezeColors;

ax(2)=subplot(4,1,2:4);
imagesc(timevec_song,[],FILT_DATA');
colormap(hot);
ylabel('Trial');
xlabel('Time (s)');
freezeColors;
hold on;

