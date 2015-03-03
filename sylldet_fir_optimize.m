function IDXS=sylldet_fir_optimize(COEFFS,FILTERED_DATA,TARGET_IDXS)
%
%
%



order=length(COEFFS);
step_size=100; % stepsize in samples
steps_forward=unique([1 step_size:step_size:order]);
trials=1:min(size(FILTERED_DATA,2),20);

[nsamples,ntrials]=size(FILTERED_DATA);

snr_vec_forward=zeros(1,length(steps_forward));

for i=1:length(steps_forward)

	% matched template is flipped average, start moving from first to last point

	tmp_filter=COEFFS(steps_forward(i):order);
	new_hitmat=filter(tmp_filter,1,FILTERED_DATA(:,trials));
	snr_vec_forward(i)=median(sylldet_eval_filter_snr(new_hitmat,TARGET_IDXS));

end

fig=figure();
plot(steps_forward,snr_vec_forward);
ylabel('SNR');
xlabel('Points trimmed from filter coefficients');

selection=input('Enter the cut point: ');
close([fig]);

% change to user input here

steps_backward=selection+step_size:step_size:order;
snr_vec_backward=zeros(1,length(steps_backward));

for i=1:length(steps_backward)

	tmp_filter=COEFFS(selection:steps_backward(i));
	new_hitmat=filter(tmp_filter,1,FILTERED_DATA(:,trials));
	snr_vec_backward(i)=median(sylldet_eval_filter_snr(new_hitmat,TARGET_IDXS));
end

fig=figure();
plot(steps_backward,snr_vec_backward);
ylabel('SNR');
xlabel('Points from the first cutoff');

selection2=input('Enter the number of points to include from the cut point:  ');

IDXS=[selection selection2];
