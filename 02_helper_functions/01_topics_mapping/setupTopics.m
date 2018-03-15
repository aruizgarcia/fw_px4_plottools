function [topics] = setupTopics()
% topics mapping for the latest master

topics = struct;
topics.actuator_controls = ...
    struct('topic_name', 'actuator_controls_0', 'logged', false, 'num_instances', 0);
topics.actuator_outputs = ...
    struct('topic_name', 'actuator_outputs', 'logged', false, 'num_instances', 0);
topics.airspeed = ...
    struct('topic_name', 'airspeed', 'logged', false, 'num_instances', 0);
topics.battery_status = ...
    struct('topic_name', 'battery_status', 'logged', false, 'num_instances', 0);
topics.commander_state = ...
    struct('topic_name', 'commander_state', 'logged', false, 'num_instances', 0);
topics.cpuload = ...
    struct('topic_name', 'commander_state', 'logged', false, 'num_instances', 0);
topics.control_state = ...
    struct('topic_name', 'control_state', 'logged', false, 'num_instances', 0);
topics.cpuload = ...
    struct('topic_name', 'cpuload', 'logged', false, 'num_instances', 0);
topics.differential_pressure = ...
    struct('topic_name', 'differential_pressure', 'logged', false, 'num_instances', 0);
topics.distance_sensor = ...
    struct('topic_name', 'distance_sensor', 'logged', false, 'num_instances', 0);
topics.ekf2_innovations = ...
    struct('topic_name', 'ekf2_innovations', 'logged', false, 'num_instances', 0);
topics.ekf2_timestamps = ...
    struct('topic_name', 'ekf2_timestamps', 'logged', false, 'num_instances', 0);
topics.estimator_status = ...
    struct('topic_name', 'estimator_status', 'logged', false, 'num_instances', 0);
topics.home_position = ...
    struct('topic_name', 'home_position', 'logged', false, 'num_instances', 0);
topics.input_rc = ...
    struct('topic_name', 'input_rc', 'logged', false, 'num_instances', 0);
topics.manual_control_setpoint = ...
    struct('topic_name', 'manual_control_setpoint', 'logged', false, 'num_instances', 0);
topics.mission_result = ...
    struct('topic_name', 'mission_result', 'logged', false, 'num_instances', 0);
topics.position_setpoint_triplet = ...
    struct('topic_name', 'position_setpoint_triplet', 'logged', false, 'num_instances', 0);
topics.rc_channels = ...
    struct('topic_name', 'rc_channels', 'logged', false, 'num_instances', 0);
topics.sensor_combined = ...
    struct('topic_name', 'sensor_combined', 'logged', false, 'num_instances', 0);
topics.sensor_preflight = ...
    struct('topic_name', 'sensor_preflight', 'logged', false, 'num_instances', 0);
topics.sensor_accel = ...
    struct('topic_name', 'sensor_accel', 'logged', false, 'num_instances', 0);
topics.sensor_baro = ...
    struct('topic_name', 'sensor_baro', 'logged', false, 'num_instances', 0);
topics.sensor_gyro = ...
    struct('topic_name', 'sensor_gyro', 'logged', false, 'num_instances', 0);
topics.sensor_mag = ...
    struct('topic_name', 'sensor_mag', 'logged', false, 'num_instances', 0);
topics.system_power = ...
    struct('topic_name', 'system_power', 'logged', false, 'num_instances', 0);
topics.task_stack_info = ...
    struct('topic_name', 'task_stack_info', 'logged', false, 'num_instances', 0);
topics.tecs_status = ...
    struct('topic_name', 'tecs_status', 'logged', false, 'num_instances', 0);
topics.telemetry_status = ...
    struct('topic_name', 'telemetry_status', 'logged', false, 'num_instances', 0);
topics.vehicle_attitude = ...
    struct('topic_name', 'vehicle_attitude', 'logged', false, 'num_instances', 0);
topics.vehicle_attitude_setpoint = ...
    struct('topic_name', 'vehicle_attitude_setpoint', 'logged', false, 'num_instances', 0);
topics.vehicle_command = ...
    struct('topic_name', 'vehicle_command', 'logged', false, 'num_instances', 0);
topics.vehicle_control_mode = ...
    struct('topic_name', 'vehicle_control_mode', 'logged', false, 'num_instances', 0);
topics.vehicle_global_position = ...
    struct('topic_name', 'vehicle_global_position', 'logged', false, 'num_instances', 0);
topics.vehicle_gps_position = ...
    struct('topic_name', 'vehicle_gps_position', 'logged', false, 'num_instances', 0);
topics.vehicle_land_detection = ...
    struct('topic_name', 'vehicle_land_detection', 'logged', false, 'num_instances', 0);
topics.vehicle_local_position = ...
    struct('topic_name', 'vehicle_local_position', 'logged', false, 'num_instances', 0);
topics.vehicle_rates_setpoint = ...
    struct('topic_name', 'vehicle_rates_setpoint', 'logged', false, 'num_instances', 0);
topics.vehicle_status = ...
    struct('topic_name', 'vehicle_status', 'logged', false, 'num_instances', 0);
topics.vehicle_status_flags = ...
    struct('topic_name', 'vehicle_status_flags', 'logged', false, 'num_instances', 0);
topics.wind_estimate = ...
    struct('topic_name', 'wind_estimate', 'logged', false, 'num_instances', 0);
