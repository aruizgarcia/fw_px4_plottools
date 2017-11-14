% This Matlab Script can be used to import the binary logged values of the
% PX4FMU into data that can be plotted and analyzed.

%% ************************************************************************
% logconv: Main function
% ************************************************************************
function logconv()
% Clear everything
clc;
clear all;
close all;
path(path,'01_draw_functions');
path(path,'01_draw_functions/01_subfunctions');
path(path,'02_helper_functions');
path(path,'03_kmltoolbox_v2.6');
path(path,'04_log_files');
path(path,'05_csv_files');
path(path,'06_mat_files');
path(path,'07_kmz_files');

% ************************************************************************
% SETTINGS (modify necessary parameter)
% ************************************************************************

% set the path to your log file here file here
fileName = 'log001.ulg';

% the source from which the data is imported
% 0: converting the ulog to csv files and then parsing the csv files
%    (required for the first run)
% 1: only parsing the pre-existing csv files
%    (requires the generated csv files)
% 2: import the data from the .mat file
%    (requires the generated .mat file)
% else: Defaults to 0
loadingMode = 0;

% Print information while converting/loading the log file in mode 0 or 1.
% Helpfull to identify field missmatchs.
loadingVerbose = false;

% indicates if the sysvector map and the topics struct should be saved
% after they are generated.
saveMatlabData = true;

% delete the csv file after a run of the script
deleteCSVFiles = true;

% id of the vehicle (note displaying the logs multiple vehicles at the same
% time is not supported yet)
vehicleID = 0;

% delimiter for the path
%   '/' for ubuntu
%   '\' for windows
pathDelimiter = '/';

% indicates if the plots should be generated. If set to false the log file
% is only converted to the sysvector.
generatePlots = true;

% only plot the logged data from t_start to t_end. If both are set to 0.0
% all the logged data is plotted.
t_start = 0.0;
t_end = 0.0;

% change topic names or add new topics in the setupTopics function.

% ************************************************************************
% SETTINGS end
% ************************************************************************

% ******************
% Import the data
% ******************

% get the file name without the file ending
plainFileName = char(extractBefore(fileName,'.'));

% conversion factors
fconv_timestamp=1E-6;    % [microseconds] to [seconds]
fconv_gpsalt=1E-3;       % [mm] to [m]
fconv_gpslatlong=1E-7;   % [gps_raw_position_unit] to [deg]

if loadingMode==2
    if exist([plainFileName '.mat'], 'file') == 2
        load([plainFileName '.mat']);
        if (numel(fieldnames(topics)) == 0) || (sysvector.Count == 0)
            error(['Sysvector and/or topics loaded from the .mat file are empty.' newline ...
                'Run script first with loadingMode=0 and saveMatlabData=true'])
        end
    else
        error(['Could not load the data as the file does not exist.' newline ...
            'Run script first with loadingMode=0 and saveMatlabData=true'])
    end
else
    % setup the topics which could have been logged
    topics = struct;
    setupTopics();
    
    % import the data
    sysvector = containers.Map();
    ImportPX4LogData();
end

% ******************
% Crop the data
% ******************
sysvector_keys = sysvector.keys';
CropPX4LogData();

% ******************
% Print the data
% ******************

if generatePlots
    DisplayPX4LogData(sysvector, topics, plainFileName, fconv_gpsalt, fconv_gpslatlong)
end


%% ************************************************************************
%  *** END OF MAIN SCRIPT ***
%  NESTED FUNCTION DEFINTIONS FROM HERE ON
%  ************************************************************************

%% ************************************************************************
%  setupTopics (nested function)
%  ************************************************************************
%  Specify the struct of topics. Each topic contains a topic name and
%  boolean which tells if that topic was logged (default value must be
%  false)
%  Only rearrange the field names if they changed in the message 
%  definition. If the names are changed all the plotting scripts need to be
%  adopted. The fields list does not include the timestamp which is the
%  first entry of the csv file.

function setupTopics()
    % Edit only the topic names of the existing topics or add a new one
    topics.actuator_controls = ...
        struct('topic_name', 'actuator_controls_0', 'logged', false,...
        'fields', [string('timestamp_sample'), string('control_0'), string('control_1') , string('control_2'),...
        string('control_3'), string('control_4'), string('control_5'), string('control_6'), string('control_7')]);
    topics.actuator_outputs = ...
        struct('topic_name', 'actuator_outputs', 'logged', false,...
        'fields', [string('noutputs'), string('output_0'), string('output_1') , string('output_2'),...
        string('output_3'), string('output_4'), string('output_5'), string('output_6'), string('output_7'),...
        string('output_8'), string('output_9'), string('output_10'), string('output_11'), string('output_12'),...
        string('output_13'), string('output_14'), string('output_15')]);
    topics.airspeed = ...
        struct('topic_name', 'airspeed', 'logged', false,...
        'fields', [string('indicated_airspeed'), string('true_airspeed'), ...
        string('true_airspeed_unfiltered') , string('air_temperature'), string('confidence')]);
    topics.battery_status = ...
        struct('topic_name', 'battery_status', 'logged', false,...
        'fields', [string('v'), string('v_filtered'), string('i'), string('i_filtered'), string('discharged_mah'),...
        string('remaining') , string('scale'), string('cell_count'), string('connected'), string('system_source'), string('priority'), string('warning')]);
    topics.commander_state = ...
        struct('topic_name', 'commander_state', 'logged', false,...
        'fields', [string('main_state')]);
    topics.control_state = ...
        struct('topic_name', 'control_state', 'logged', false,...
        'fields', [string('x_acc'), string('y_acc'), string('z_acc') , string('x_vel'), string('y_vel'), string('z_vel'),...
        string('x_pos'), string('y_pos'), string('z_pos'), string('airspeed'), string('vel_var_0'), string('vel_var_1'),...
        string('vel_var_2'), string('pos_var_0'), string('pos_var_1'), string('pos_var_2'), string('q0'), string('q1'),...
        string('q2'), string('q3'), string('delta_q_reset_0'), string('delta_q_reset_1'), string('delta_q_reset_2'),...
        string('delta_q_reset_3'), string('roll_rate'), string('pitch_rate'), string('yaw_rate'),...
        string('horz_acc_mag'), string('roll_rate_bias'), string('pitch_rate_bias'), string('yaw_rate_bias'),...
        string('airspeed_valid'), string('quat_reset_counter')]);
    topics.cpuload = ...
        struct('topic_name', 'cpuload', 'logged', false,...
        'fields', [string('load'), string('ram_usage')]);
    topics.differential_pressure = ...
        struct('topic_name', 'differential_pressure', 'logged', false,...
        'fields', [string('error_count'), string('differential_pressure_raw'),...
        string('differential_pressure_filtered'), string('temperature'), string('device_id')]);
    topics.ekf2_innovations = ...
        struct('topic_name', 'ekf2_innovations', 'logged', false,...
        'fields', [string('vel_pos_0'), string('vel_pos_1'), string('vel_pos_2') , string('vel_pos_3'),...
        string('vel_pos_4'), string('vel_pos_5'), string('mag_0'), string('mag_1'), string('mag_2'), string('heading'),...
        string('airspeed'), string('beta'), string('flow_0'), string('flow_1'), string('hagl'), string('vel_pos_0_var'),...
        string('vel_pos_1_var'), string('vel_pos_2_var'), string('vel_pos_3_var'), string('vel_pos_4_var'),...
        string('vel_pos_5_var'), string('mag_0_var'), string('mag_1_var'), string('mag_2_var'), string('heading_var'),...
        string('airspeed_var'), string('beta_var'), string('flow_0_var'), string('flow_1_var'), string('hagl_var'),...
        string('output_tracking_error_0'), string('output_tracking_error_1'), string('output_tracking_error_2'),...
        string('drag_0'), string('drag_1'), string('drag_0_var'), string('drag_1_var')]);
    topics.ekf2_timestamps = ...
        struct('topic_name', 'ekf2_timestamps', 'logged', false,...
        'fields', [string('gps_timestamp_rel'), string('optical_flow_timestamp_rel'),...
        string('distance_sensor_timestamp_rel'), string('airspeed_timestamp_rel'), ...
        string('vision_position_timestamp_rel'), string('vision_attitude_timestamp_rel')]);
    topics.estimator_status = ...
        struct('topic_name', 'estimator_status', 'logged', false,...
        'fields', [string('states_0'), string('states_1'), string('states_2') , string('states_3'),...
        string('states_4'), string('states_5'), string('states_6'), string('states_7'), string('states_8'), string('states_9'),...
        string('states_10'), string('states_11'), string('states_12'), string('states_13'), string('states_14'), string('states_15'),...
        string('states_16'), string('states_17'), string('states_18'), string('states_19'), string('states_20'),...
        string('states_21'), string('states_22'), string('states_23'), string('n_states'), string('vibe_0'),...
        string('vibe_1'), string('vibe_2'), string('covar_0'), string('covar_1'), string('covar_2'), string('covar_3'),...
        string('covar_4'), string('covar_5'), string('covar_6'), string('covar_7'), string('covar_8'), string('covar_9'),...
        string('covar_10'), string('covar_11'), string('covar_12'), string('covar_13'), string('covar_14'), string('covar_15'),...
        string('covar_16'), string('covar_17'), string('covar_18'), string('covar_19'), string('covar_20'), string('covar_21'),...
        string('covar_22'), string('covar_23'), string('control_mode_flags'), string('pos_horiz_accuracy'),...
        string('pos_vert_accuracy'), string('mag_test_ratio'), string('vel_test_ratio'), string('pos_test_ratio'),...
        string('hgt_test_ratio'), string('tas_test_ratio'), string('hagl_test_ratio'), string('time_slip'),...
        string('gps_check_fail_flags'), string('filter_fault_flags'), string('innovation_check_flags'),...
        string('solution_status_flags'), string('nan_flags'), string('health_flags'), string('timeout_flags')]);
    topics.position_setpoint_triplet = ...
        struct('topic_name', 'position_setpoint_triplet', 'logged', false,...
        'fields', [string('prev_timestamp'), string('prev_lat'), string('prev_lon') , string('prev_x'),...
        string('prev_y'), string('prev_z'), string('prev_vx'), string('prev_vy'), string('prev_vz'), string('prev_alt'),...
        string('prev_yaw'), string('prev_yawspeed'), string('prev_loiter_radius'), string('prev_pitch_min'),...
        string('prev_a_x'), string('prev_a_y'), string('prev_a_z'), string('prev_acceptance_radius'), string('prev_cruising_speed'),...
        string('prev_cruising_throttle'), string('prev_valid'), string('prev_type'), string('prev_position_valid'),...
        string('prev_velocity_valid'), string('prev_velocity_frame'), string('prev_alt_valid'), string('prev_yaw_valid'),...
        string('prev_disable_mc_yaw_control'), string('prev_yawspeed_valid'), string('prev_loiter_direction'),...
        string('prev_acceleration_valid'), string('prev_acceleration_is_force'),...
        string('curr_timestamp'), string('curr_lat'), string('curr_lon') , string('curr_x'),...
        string('curr_y'), string('curr_z'), string('curr_vx'), string('curr_vy'), string('curr_vz'), string('curr_alt'),...
        string('curr_yaw'), string('curr_yawspeed'), string('curr_loiter_radius'), string('curr_pitch_min'),...
        string('curr_a_x'), string('curr_a_y'), string('curr_a_z'), string('curr_acceptance_radius'), string('curr_cruising_speed'),...
        string('curr_cruising_throttle'), string('curr_valid'), string('curr_type'), string('curr_position_valid'),...
        string('curr_velocity_valid'), string('curr_velocity_frame'), string('curr_alt_valid'), string('curr_yaw_valid'),...
        string('curr_disable_mc_yaw_control'), string('curr_yawspeed_valid'), string('curr_loiter_direction'),...
        string('curr_acceleration_valid'), string('curr_acceleration_is_force'),...
        string('next_timestamp'), string('next_lat'), string('next_lon') , string('next_x'),...
        string('next_y'), string('next_z'), string('next_vx'), string('next_vy'), string('next_vz'), string('next_alt'),...
        string('next_yaw'), string('next_yawspeed'), string('next_loiter_radius'), string('next_pitch_min'),...
        string('next_a_x'), string('next_a_y'), string('next_a_z'), string('next_acceptance_radius'), string('next_cruising_speed'),...
        string('next_cruising_throttle'), string('next_valid'), string('next_type'), string('next_position_valid'),...
        string('next_velocity_valid'), string('next_velocity_frame'), string('next_alt_valid'), string('next_yaw_valid'),...
        string('next_disable_mc_yaw_control'), string('next_yawspeed_valid'), string('next_loiter_direction'),...
        string('next_acceleration_valid'), string('next_acceleration_is_force')]);
    topics.input_rc = ...
        struct('topic_name', 'input_rc', 'logged', false,...
        'fields', [string('timestamp_last_signal'), string('channel_count'), string('rssi'),...
        string('rc_lost_frame_count'), string('rc_total_frame_count'), string('rc_ppm_frame_length'),...
        string('val_0'), string('val_1'), string('val_2'), string('val_3'), string('val_4'), string('val_5'), string('val_6'),...
        string('val_7'), string('val_8'), string('val_9'), string('val_10'), string('val_11'), string('val_12'), string('val_13'),...
        string('val_14'), string('val_15'), string('val_16'), string('val_17'), string('rc_failsafe'), string('rc_lost'),...
        string('input_source')]);
    topics.sensor_combined = ...
        struct('topic_name', 'sensor_combined', 'logged', false,...
        'fields', [string('gyro_0'), string('gyro_1'), string('gyro_2') , string('gyro_integral_dt'),...
        string('acc_timestamp_relative'), string('acc_0'), string('acc_1'), string('acc_2'), string('acc_integral_dt'),...
        string('mag_timestamp_relative'), string('mag_0'), string('mag_1'), string('mag_2'),...
        string('baro_timestamp_relative'), string('baro_alt'), string('baro_temp')]);
    topics.sensor_preflight = ...
        struct('topic_name', 'sensor_preflight', 'logged', false,...
        'fields', [string('acc_inconsistency'), string('gyro_inconsistency'), string('mag_inconsystency')]);
    topics.sensor_accel = ...
        struct('topic_name', 'sensor_accel', 'logged', false,...
        'fields', [string('integral_dt'), string('error_count'), string('x'), string('y'), string('z'), string('x_integral'),...
        string('y_integral'), string('z_integral'), string('temperature'), string('range_m_s2'), string('scaling'),...
        string('device_id'), string('x_raw'), string('y_raw'), string('z_raw'), string('temperature_raw')]);
    topics.sensor_baro = ...
        struct('topic_name', 'sensor_baro', 'logged', false,...
        'fields', [string('error_count'), string('pressure'), string('altitude'), string('temperature'),...
        string('device_id')]);
    topics.sensor_gyro = ...
        struct('topic_name', 'sensor_gyro', 'logged', false,...
        'fields', [string('integral_dt'), string('error_count'), string('x'), string('y'), string('z'), string('x_integral'),...
        string('y_integral'), string('z_integral'), string('temperature'), string('range_rad_s'), string('scaling'),...
        string('device_id'), string('x_raw'), string('y_raw'), string('z_raw'), string('temperature_raw')]);
    topics.sensor_mag = ...
        struct('topic_name', 'sensor_mag', 'logged', false,...
        'fields', [string('error_count'), string('x'), string('y'), string('z'), string('range_ga'), string('scaling'), ...
        string('temperature'), string('device_id'), string('x_raw'), string('y_raw'), string('z_raw'), string('is_external')]);
    topics.system_power = ...
        struct('topic_name', 'system_power', 'logged', false,...
        'fields', [string('voltage5V'), string('voltage3.3V'), string('v3.3V_valid'), string('usb_connected'),...
        string('brick_valid'), string('usb_valid'), string('servo_valid'), string('periph_5V_OC'), string('hipower_5V_OC')]);
    topics.task_stack_info = ...
        struct('topic_name', 'task_stack_info', 'logged', false,...
        'fields', [string('stack_free'), string('task_0'), string('task_1') , string('task_2'),...
        string('task_3'), string('task_4'), string('task_5'), string('task_6'), string('task_7'), string('task_8'),...
        string('task_9'), string('task_10'), string('task_11'), string('task_12'),...
        string('task_13'), string('task_14'), string('task_15')]);
    topics.tecs_status = ...
        struct('topic_name', 'tecs_status', 'logged', false,...
        'fields', [string('altitudeSp'), string('altitude_filtered'), string('flightPathAngleSp'),...
        string('flightPathAngle'), string('airspeedSp'), string('airspeed_filtered'),...
        string('airspeedDerivativeSp'), string('airspeedDerivative'), string('totalEnergyError'),...
        string('energyDistributionError'), string('totalEnergyRateError'), string('energyDistributionRateError'),...
        string('throttle_integ'), string('pitch_integ'), string('mode')]);
    topics.telemetry_status = ...
        struct('topic_name', 'telemetry_status', 'logged', false,...
        'fields', [string('heartbeat_time'), string('telem_time'), string('rxerrors'), string('fixed'),...
        string('type'), string('rssi'), string('remote_rssi'), string('noise'), string('remote_noise'), string('txbuf'),...
        string('system_id'), string('component_id')]);
    topics.vehicle_attitude = ...
        struct('topic_name', 'vehicle_attitude', 'logged', false,...
        'fields', [string('rollspeed'), string('pitchspeed'), string('yawspeed'), string('q_0'),...
        string('q_1'), string('q_2'), string('q_3'), string('delta_q_reset_0'), string('delta_q_reset_1')...
        string('delta_q_reset_2'), string('delta_q_reset_3'), string('quat_reset_counter')]);
    topics.vehicle_attitude_setpoint = ...
        struct('topic_name', 'vehicle_attitude_setpoint', 'logged', false,...
        'fields', [string('roll_body'), string('pitch_body'), string('yaw_body'), string('yaw_sp_move_rate'),...
        string('q_d_0'), string('q_d_1'), string('q_d_2'), string('q_d_3'), string('thrust'), string('landing_gear'),...
        string('q_d_valid'), string('roll_reset_integral'), string('pitch_reset_integral'),...
        string('yaw_reset_integral'), string('fw_control_yaw'), string('disable_mc_yaw_control'),...
        string('apply_flaps')]);
    topics.vehicle_command = ...
        struct('topic_name', 'vehicle_command', 'logged', false,...
        'fields', [string('param5'), string('param6'), string('param1'), string('param2'), string('param3'),...
        string('param4'), string('param7'), string('command'), string('target_system'), string('target_component'),...
        string('source_system'), string('source_component'), string('confirmation'), string('from_external')]);
    topics.vehicle_global_position = ...
        struct('topic_name', 'vehicle_global_position', 'logged', false,...
        'fields', [string('lat'), string('lon'), string('alt'), string('delta_alt'), string('vel_n'), string('vel_e'),...
        string('vel_d'), string('pos_d_deriv'), string('yaw'), string('eph'), string('epv'), string('evh'), string('evv'),...
        string('terrain_alt'), string('pressure_alt'), string('lat_lon_reset_counter'), string('alt_reset_counter'), ...
        string('terrain_alt_valid'), string('dead_reckoning')]);
    topics.vehicle_gps_position = ...
        struct('topic_name', 'vehicle_gps_position', 'logged', false,...
        'fields', [string('time_utc'), string('lat'), string('lon'), string('alt'), string('alt_ellipsoid')...
        string('s_variance'), string('c_variance'), string('eph'), string('epv'), string('hdop'), string('vdop'),...
        string('noise_per_ms'), string('jamming_indicator'), string('vel'), string('vel_n'), string('vel_e'), string('vel_d'),...
        string('cog'), string('timestamp_time_relative'), string('fix_type'),...
        string('vel_ned_valid'), string('satellites_used')]);
    topics.vehicle_land_detection = ...
        struct('topic_name', 'vehicle_land_detection', 'logged', false,...
        'fields', [string('alt_max'), string('landed'), string('freefall'), string('ground_contact')]);
    topics.vehicle_local_position = ...
        struct('topic_name', 'vehicle_local_position', 'logged', false,...
        'fields', [string('ref_timestamp'), string('ref_lat'), string('ref_lon'), ...
        string('x'), string('y'), string('z'), string('delta_xy_0'),...
        string('delta_xy_1'), string('delta_z'), string('vx'), string('vy'), string('vz'), string('z_deriv'), string('delta_vxy0'),...
        string('delta_vxy_1'), string('delta_vz'), string('ax'), string('ay'), string('az'), string('yaw'), string('ref_alt'),...
        string('dist_bottom'), string('dist_bottom_rate'), string('eph'), string('epv'), string('evh'), string('evv'),...
        string('xy_valid'), string('z_valid'), string('v_xy_valid'), string('v_z_valid'),...
        string('xy_reset_counter'), string('z_reset_counter'), string('vxy_reset_counter'), string('vz_reset_counter'),...
        string('xy_global'), string('z_global'), string('dist_bottom_valid')]);
    topics.vehicle_rates_setpoint = ...
        struct('topic_name', 'vehicle_rates_setpoint', 'logged', false,...
        'fields', [string('roll'), string('pitch'), string('yaw'), string('thrust')]);
    topics.vehicle_status = ...
        struct('topic_name', 'vehicle_status', 'logged', false,...
        'fields', [string('sys_id'), string('component_id'), string('onboard_control_sensors_present'),...
        string('onboard_control_sensors_enabled'), string('onboard_control_sensors_health'),...
        string('nav_state'), string('arming_state'), string('hil_state'), string('failsafe'), string('sys_type'),...
        string('is_rw'), string('is_vtol'), string('vtol_fw_permanent_stab'), string('in_transition_mode'), string('in_transition_to_fw')...
        string('rc_signal_lost'), string('rc_input_mode'), string('data_link_lost'), ...
        string('data_link_lost_counter'), string('engine_failure'), string('engine_failure_cmd'), ...
        string('mission_failure')]);
    topics.wind_estimate = ...
        struct('topic_name', 'wind_estimate', 'logged', false,...
        'fields', [string('north'), string('east'), string('var_north'), string('var_east')]);
end


%% ************************************************************************
%  ImportPX4LogData (nested function)
%  ************************************************************************
%  Import the data from the log file.

function ImportPX4LogData()
    disp('INFO: Start importing the log data.')
    
    if exist(fileName, 'file') ~= 2
        error('Log file does not exist.')
    end

    % *********************************
    % convert the log file to csv files
    % *********************************
    if (loadingMode~=1) && (loadingMode~=2)
        tic;
        system(sprintf('ulog2csv 04_log_files%s%s -o 05_csv_files', pathDelimiter, fileName));
        time_csv_conversion = toc;
        disp(['INFO: Converting the ulog file to csv took ' char(num2str(time_csv_conversion)) ' s.'])
    end
    
    % *********************************
    % unpack the csv files
    % *********************************
    disp('INFO: Starting to import the csv data into matlab.')
    tic;
    topic_fields = fieldnames(topics);
    
    if numel(topic_fields) == 0
        error('No topics specified in the setupTopics() function.') 
    end
    
    force_debug = false;
    for idx_topics = 1:numel(topic_fields)
        csv_file = ...
            [plainFileName '_' topics.(topic_fields{idx_topics}).topic_name...
            '_' char(num2str(vehicleID)) '.csv'];
        if exist(csv_file, 'file') == 2
            try
                csv_data = tdfread(csv_file, ',');
                csv_fields = fieldnames(csv_data);
                
                if ((numel(fieldnames(csv_data))-1) ~= numel(topics.(topic_fields{idx_topics}).fields))
                    disp(['The number of data fields in the csv file is not equal to' ...
                        ' the ones specified in the topics struct for '...
                        topic_fields{idx_topics} '. Check that the mapping is correct']);
                    force_debug = true;
                end

                for idx = 2:numel(csv_fields)
                    ts = timeseries(csv_data.(csv_fields{idx}), ...
                        csv_data.timestamp*fconv_timestamp, ...
                        'Name', [topic_fields{idx_topics} '.' char(topics.(topic_fields{idx_topics}).fields(idx-1))]);
                    ts.DataInfo.Interpolation = tsdata.interpolation('zoh');
                    sysvector([topic_fields{idx_topics} '.' char(topics.(topic_fields{idx_topics}).fields(idx-1))]) = ts;

                    if loadingVerbose || force_debug
                        str = sprintf('%s \t\t\t %s',...
                            topics.(topic_fields{idx_topics}).fields(idx-1),...
                            string(csv_fields{idx}));
                        disp(str)
                    end
                end

                topics.(topic_fields{idx_topics}).logged = true;
            catch
                disp(['Could not process the topic: ' char(topic_fields{idx_topics})]);
            end
        end
        force_debug = false;
    end
    
    % manually add a value for the commander state with the timestamp of
    % the latest global position estimate as they are used together
    if topics.commander_state.logged && topics.vehicle_global_position.logged
       ts_temp = append(sysvector('commander_state.main_state'),...
           timeseries(sysvector('commander_state.main_state').Data(end),...
           sysvector('vehicle_global_position.lon').Time(end)));
       ts_temp.DataInfo.Interpolation = tsdata.interpolation('zoh');
       ts_temp.Name = 'commander_state.main_state';
       sysvector('commander_state.main_state') = ts_temp;
    end

    time_csv_import = toc;
    disp(['INFO: Importing the csv data to matlab took ' char(num2str(time_csv_import)) ' s.'])

    % check that we have a nonempy sysvector
    if (loadingMode~=1) && (loadingMode~=2)
        if sysvector.Count == 0
            error(['Empty sysvector: Converted the ulog file to csv and parsed it.' newline ...
                'Contains the logfile any topic specified in the setupTopics() function?'])
        end
    else
        if sysvector.Count == 0
            error(['Empty sysvector: Tried to read directly from the csv files.' newline ...
                'Does any csv file for a topic specified the setupTopics() function exist?'])
        end
    end
    
    % *********************************
    % remove duplicate timestamps
    % *********************************
    sysvec_keys = sysvector.keys;
    for idx_key = 1:numel(sysvec_keys)
        % copy data info
        data_info = sysvector(sysvec_keys{idx_key}).DataInfo;
                
        % remove duplicate timestamps
        [~,idx_unique,~] = unique(sysvector(sysvec_keys{idx_key}).Time,'legacy');
        ts_temp = getsamples(sysvector(sysvec_keys{idx_key}), idx_unique);

        ts_temp.DataInfo = data_info;
        sysvector(sysvec_keys{idx_key}) = ts_temp;
    end
   
    % *********************************
    % save the sysvector and topics struct if requested
    % *********************************
    if saveMatlabData
        save(['06_mat_files' pathDelimiter plainFileName '.mat'], 'sysvector', 'topics');
    end
    
    % *********************************
    % delete the csv files if requested
    % *********************************
    if deleteCSVFiles
        system(sprintf('rm 05_csv_files%s%s_*', pathDelimiter, plainFileName));
    end
    
    disp('INFO: Finished importing the log data.')
end


%% ************************************************************************
%  CropPX4LogData (nested function)
%  ************************************************************************
%  Import the data from the log file.

function CropPX4LogData()
    if (t_start == 0.0 && t_end == 0.0)
        disp('INFO: Not cropping the logging data.')
        return;
    end
    if (t_start > t_end)
        disp('INFO: t_start > t_end: not cropping the logging data.')
        return;
    end
    
    disp('INFO: Start cropping the log data.')
    
    for idx_key = 1:numel(sysvector_keys)
        % copy data info
        data_info = sysvector(sysvector_keys{idx_key}).DataInfo;
        
        % crop time series
        ts_temp = getsampleusingtime(sysvector(sysvector_keys{idx_key}), t_start, t_end);
        ts_temp.DataInfo = data_info;
        sysvector(sysvector_keys{idx_key}) = ts_temp;
    end
    
    disp('INFO: Finshed cropping the log data.')
end

end