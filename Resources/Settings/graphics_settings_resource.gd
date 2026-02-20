class_name GraphicsSettingsResource
extends Resource

@export var scaling_3d_mode: Viewport.Scaling3DMode = Viewport.SCALING_3D_MODE_BILINEAR
@export_range(0.25, 2) var scaling_3d_scale: float = 1.0
@export var msaa_2d: Viewport.MSAA = Viewport.MSAA_4X
@export var msaa_3d: Viewport.MSAA = Viewport.MSAA_4X
@export var ssaa: Viewport.ScreenSpaceAA = Viewport.SCREEN_SPACE_AA_DISABLED
@export var taa: bool = false
@export var debanding: bool = false

@export var tonemap_mode: Environment.ToneMapper = Environment.TONE_MAPPER_FILMIC
@export var tonemap_exposure: float = 0.8
@export var tonemap_white: float = 3.0

@export var ssao_enabled: bool = true
@export var ssao_radius: float = 0.5
@export var ssao_intensity: float = 1.5
@export var ssao_power: float = 4.0
@export var ssao_detail: float = 0.2
@export var ssao_horizon: float = 0.2
@export var ssao_sharpness: float = 2.0
@export var ssao_light_affect: float = 0.0
@export var ssao_ao_channel_affect: float = 0.0
@export var ssao_quality: RenderingServer.EnvironmentSSAOQuality = RenderingServer.ENV_SSAO_QUALITY_MEDIUM
@export var ssao_half_size: bool = false
@export var ssao_adaptive_target: float = 0.5
@export var ssao_blur_passes: int = 0
@export var ssao_fadeout_from: float = 50.0
@export var ssao_fadeout_to: float = 300.0

@export var ssil_enabled: bool = false
@export var ssil_radius: float = 5.0
@export var ssil_intensity: float = 1.0
@export var ssil_sharpness: float = 0.98
@export var ssil_normal_rejection: float = 1.0
@export var ssil_quality: RenderingServer.EnvironmentSSILQuality = RenderingServer.ENV_SSIL_QUALITY_MEDIUM
@export var ssil_half_size: bool = false
@export var ssil_adaptive_target: float = 0.5
@export var ssil_blur_passes: int = 2
@export var ssil_fadeout_from: float = 50.0
@export var ssil_fadeout_to: float = 300.0

@export var glow_enabled: bool = true
@export var glow_levels: Array[float] = [0.0, 0.8, 0.4, 0.1, 1.0, 0.0, 0.0]
@export var glow_upscale_mode: bool = false
@export var glow_normalized: bool = false
@export var glow_intensity: float = 0.3
@export var glow_strength: float = 1.0
@export var glow_bloom: float = 0.0
@export var glow_blend_mode: Environment.GlowBlendMode = Environment.GLOW_BLEND_MODE_SCREEN

@export var ssr_enabled: bool = false

@export var sss_quality: RenderingServer.SubSurfaceScatteringQuality = RenderingServer.SUB_SURFACE_SCATTERING_QUALITY_DISABLED
@export var sss_scale: float = 0.05
@export var sss_depth_scale: float = 0.01

@export var fog_enabled: bool = true
@export var fog_mode: Environment.FogMode = Environment.FOG_MODE_DEPTH
@export var fog_light_energy: float = 0.0
@export var fog_sun_scatter: float = 0.0
@export var fog_density: float = 1.0
@export var fog_sky_affect: float = 1.0
@export var fog_height: float = 0.0
@export var fog_height_density: float = 0.0
@export var fog_depth_curve: float = 1.0
@export var fog_depth_begin: float = 10.0
@export var fog_depth_end: float = 50.0

@export var volumetric_fog_enabled: bool = true
@export var volumetric_fog_volume_size: int = 128
@export var volumetric_fog_volume_depth: int = 128
@export var volumetric_fog_volume_use_filter: bool = false

@export var brightness: float = 1.0
@export var contrast: float = 1.1
@export var saturation: float = 0.9

@export var smooth_lights: bool = true

@export var directional_shadow_size: int = 4096
@export var directional_shadow_quality: RenderingServer.ShadowQuality = RenderingServer.SHADOW_QUALITY_HARD

@export var positional_shadow_size: int = 16384
@export var positional_shadow_quality: RenderingServer.ShadowQuality = RenderingServer.SHADOW_QUALITY_HARD
@export var positional_shadow_16bit: bool = true
@export var positional_shadow_atlas0: Viewport.PositionalShadowAtlasQuadrantSubdiv = Viewport.PositionalShadowAtlasQuadrantSubdiv.SHADOW_ATLAS_QUADRANT_SUBDIV_4
@export var positional_shadow_atlas1: Viewport.PositionalShadowAtlasQuadrantSubdiv = Viewport.PositionalShadowAtlasQuadrantSubdiv.SHADOW_ATLAS_QUADRANT_SUBDIV_4
@export var positional_shadow_atlas2: Viewport.PositionalShadowAtlasQuadrantSubdiv = Viewport.PositionalShadowAtlasQuadrantSubdiv.SHADOW_ATLAS_QUADRANT_SUBDIV_4
@export var positional_shadow_atlas3: Viewport.PositionalShadowAtlasQuadrantSubdiv = Viewport.PositionalShadowAtlasQuadrantSubdiv.SHADOW_ATLAS_QUADRANT_SUBDIV_4

@export var reduce_particles: bool = false
