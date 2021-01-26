extends Node

var settings := {
	"application": {
		"run": {
			"low_processor_mode": ProjectSettings.get_setting("application/run/low_processor_mode"),
		},
	},
	"audio": {
		"enable_audio_input": ProjectSettings.get_setting("audio/enable_audio_input"),
		"output_latency": ProjectSettings.get_setting("audio/output_latency"),
		"channel_disable_threshold_db": ProjectSettings.get_setting("audio/channel_disable_threshold_db"),
		"channel_disable_time": ProjectSettings.get_setting("audio/channel_disable_time"),
	},
	"rendering": {
		"quality": {
			"filters": {
				"anisotropic_filter_level": ProjectSettings.get_setting("rendering/quality/filters/anisotropic_filter_level"),
				"use_nearest_mipmap_filter": ProjectSettings.get_setting("rendering/quality/filters/use_nearest_mipmap_filter"),
				"msaa": ProjectSettings.get_setting("rendering/quality/filters/msaa"),
			},
			"directional_shadow": {
				"size": ProjectSettings.get_setting("rendering/quality/directional_shadow/size"),
			},
			"shadow_atlas": {
				"size": ProjectSettings.get_setting("rendering/quality/shadow_atlas/size"),
				"quadrant_0_subdiv": ProjectSettings.get_setting("rendering/quality/shadow_atlas/quadrant_0_sibdiv"),
				"quadrant_1_subdiv": ProjectSettings.get_setting("rendering/quality/shadow_atlas/quadrant_1_sibdiv"),
				"quadrant_2_subdiv": ProjectSettings.get_setting("rendering/quality/shadow_atlas/quadrant_2_sibdiv"),
				"quadrant_3_subdiv": ProjectSettings.get_setting("rendering/quality/shadow_atlas/quadrant_3_sibdiv"),
			},
			"shadows": {
				"filter_mode": ProjectSettings.get_setting("rendering/quality/shadows/filter_mode"),
			},
			"reflections": {
				"texture_array_reflections": ProjectSettings.get_setting("rendering/quality/reflections/texture_array_reflections"),
				"high_quality_ggx": ProjectSettings.get_setting("rendering/quality/reflections/high_quality_ggx"),
				"irradiance_max_size": ProjectSettings.get_setting("rendering/quality/reflections/irradiance_max_size"),
				"atlas_size": ProjectSettings.get_setting("rendering/quality/reflections/atlas_size"),
				"atlas_subdiv": ProjectSettings.get_setting("rendering/quality/reflections/atlas_subdiv"),
			},
			"shading": {
				"force_vertex_shading": ProjectSettings.get_setting("rendering/quality/shading/force_vertex_shading"),
				"force_lambert_over_burley": ProjectSettings.get_setting("rendering/quality/shading/force_lambert_over_burley"),
				"force_blinn_over_ggx": ProjectSettings.get_setting("rendering/quality/shading/force_blinn_over_ggx"),
			},
			"subsurface_scattering": {
				"quality": ProjectSettings.get_setting("rendering/quality/subsurface_scattering/quality"),
				"scale": ProjectSettings.get_setting("rendering/quality/subsurface_scattering/scale"),
				"follow_surface": ProjectSettings.get_setting("rendering/quality/subsurface_scattering/follow_surface"),
				"weight_samples": ProjectSettings.get_setting("rendering/quality/subsurface_scattering/weight_samples"),
			},
			"voxel_cone_tracing": {
				"high_quality": ProjectSettings.get_setting("rendering/quality/voxel_cone_tracing/high_quality"),
			},
			"depth": {
				"hdr": ProjectSettings.get_setting("rendering/quality/depth/hdr"),
			},
			"dynamic_fonts": {
				"use_oversampling": ProjectSettings.get_setting("rendering/quality/dynamic_fonts/use_oversampling"),
			},
		},
	},
	"display": {
		"window": {
			"size": {
				"width": ProjectSettings.get_setting("display/window/size/width"),
				"height": ProjectSettings.get_setting("display/window/size/height"),
				"resizable": ProjectSettings.get_setting("display/window/size/resizable"),
				"borderless": ProjectSettings.get_setting("display/window/size/borderless"),
				"fullscreen": ProjectSettings.get_setting("display/window/size/fullscreen"),
				"always_on_top": ProjectSettings.get_setting("display/window/size/always_on_top"),
			},
			"vsync": {
				"use_vsync": ProjectSettings.get_setting("display/window/vsync/use_vsync"),
				"vsync_via_compositor": ProjectSettings.get_setting("display/window/vsync/vsync_via_compositor"),
			},
			"energy_saving": {
				"keep_screen_on": ProjectSettings.get_setting("display/window/energy_saving/keep_screen_on"),
			},
		},
	},
}
