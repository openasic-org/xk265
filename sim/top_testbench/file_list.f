//--------------------------------------------
//      Include Dir
//--------------------------------------------
+incdir+./
+incdir+../../rtl/

//--------------------------------------------
//      Test Bench
//--------------------------------------------
./tb_enc_top.v


//--------------------------------------------
//      defines
//--------------------------------------------
../../rtl/enc_defines.v

//--------------------------------------------
//      memory behave
//--------------------------------------------
../../lib/behave/mem/sram_sp_be_behave.v
../../lib/behave/mem/sram_tp_be_behave.v
../../lib/behave/mem/ram_1p.v
../../lib/behave/mem/ram_2p.v
../../lib/behave/mem/ram_dp.v
../../lib/behave/mem/ram_dp_be.v
../../lib/behave/mem/rf_1p.v
../../lib/behave/mem/rf_2p.v
../../lib/behave/mem/rf_2p_be.v
../../lib/behave/mem/rom_1p.v


//--------------------------------------------
//      Memory 
//--------------------------------------------
../../rtl/mem/buf_ram_1p_128x64.v
../../rtl/mem/buf_ram_1p_64x64.v
../../rtl/mem/cabac_ram_sp_64x16.v
../../rtl/mem/db_cbf_ram_sp_64x16.v
../../rtl/mem/db_qp_ram_sp_64x20.v
../../rtl/mem/db_tupu_ram_sp_64x32.v
../../rtl/mem/db_mv_ram_sp_512x20.v
../../rtl/mem/db_mv_ram_sp_64x20.v
../../rtl/mem/fetch_ram_1p_128x32.v
../../rtl/mem/fetch_ram_2p_64x208.v
../../rtl/mem/fetch_rf_1p_128x512.v
../../rtl/mem/fetch_rf_1p_64x256.v
../../rtl/mem/ime_mv_ram_sp_64x13.v
../../rtl/mem/fme_mv_ram_dp_64x20.v
../../rtl/mem/mc_mv_ram_sp_512x20.v
../../rtl/mem/prei_md_ram_sp_85x6.v
../../rtl/mem/posi_md_ram_sp_64x6.v
../../rtl/mem/prei_ram_dp_16x32.v
../../rtl/mem/ram_sp_240x32.v
../../rtl/mem/ram_sp_256x32.v
../../rtl/mem/ram_sp_1024x32.v
../../rtl/mem/ram_sp_be_128x64.v
../../rtl/mem/ram_sp_be_192x128.v
../../rtl/mem/ram_sp_be_192x512.v
../../rtl/mem/ram_tp_be_32x64.v
../../rtl/mem/ram_sp_be_192x64.v
../../rtl/mem/ram_sp_be_64x23.v
../../rtl/mem/ram_sp_384x32.v
../../rtl/mem/ram_sp_1536x32.v
../../rtl/mem/tq_ram_sp_32x16.v
../../rtl/mem/mem_lipo_1p_128x64x4.v
../../rtl/mem/mem_lipo_1p_64x64x4.v
../../rtl/mem/mem_lipo_1p.v
../../rtl/mem/buf_ram_1p_64x192.v

//--------------------------------------------
//      ENC TOP
//--------------------------------------------
../../rtl/top/enc_core.v
../../rtl/top/enc_ctrl.v
../../rtl/top/enc_top.v
../../rtl/top/enc_data_pipeline.v
../../rtl/top/fme_top_buf.v
../../rtl/top/ime_top_buf.v
../../rtl/top/prei_top_buf.v
../../rtl/top/posi_top_buf.v


//--------------------------------------------
//      PRE_I and Rate Control
//--------------------------------------------
../../rtl/prei/hevc_md_top.v
../../rtl/prei/md_top.v
../../rtl/prei/compare.v
../../rtl/prei/control.v
../../rtl/prei/counter.v
../../rtl/prei/DC_Plannar.v
../../rtl/prei/fetch8x8.v
../../rtl/prei/gxgy.v
../../rtl/prei/md_fetch.v
../../rtl/prei/mode_write.v
../../rtl/prei/prei_top.v
../../rtl/prei/rate_control.v


//--------------------------------------------
//      POS_I
//--------------------------------------------
../../rtl/posi/posi_top.v
../../rtl/posi/posi_ctrl.v
../../rtl/posi/posi_transfer.v
../../rtl/posi/posi_reference.v
../../rtl/posi/posi_prediction.v
../../rtl/posi/posi_buffer.v
../../rtl/posi/posi_satd_cost.v
../../rtl/posi/posi_satd_cost_engine.v
../../rtl/posi/posi_satd_cost_transpose.v
../../rtl/posi/posi_partition_decision.v
../../rtl/posi/posi_memory_wrapper.v
../../rtl/posi/posi_rate_estimation.v


//--------------------------------------------
//      IME
//--------------------------------------------
../../rtl/ime/ime_top.v
../../rtl/ime/ime_transfer.v
../../rtl/ime/ime_ver_mem.v
../../rtl/ime/ime_ctrl.v
../../rtl/ime/ime_addressing.v
../../rtl/ime/ime_dat_array.v
../../rtl/ime/ime_sad_array.v
../../rtl/ime/ime_cost_store.v
../../rtl/ime/ime_partition_decision.v
../../rtl/ime/ime_partition_decision_engine.v
../../rtl/ime/ime_mv_dump.v

//--------------------------------------------
//      FME
//--------------------------------------------
../../rtl/fme/fme_buf_wrapper.v
../../rtl/fme/fme_interpolator.v
../../rtl/fme/fme_interpolator_8pel.v
../../rtl/fme/fme_interpolator_8x8.v
../../rtl/fme/fme_ip_half_ver.v
../../rtl/fme/fme_ip_quarter_ver.v
../../rtl/fme/fme_satd_8x8.v
../../rtl/fme/fme_satd_gen.v
../../rtl/fme/fme_cost.v
../../rtl/fme/fme_ctrl.v
../../rtl/fme/fme_pred.v
../../rtl/fme/fme_top.v
../../rtl/fme/fme_mv_buffer.v
../../rtl/fme/fme_mv_candidate_prepare.v
../../rtl/fme/getbits.v
../../rtl/fme/fme_skip.v
../../rtl/fme/qp_lambda_table.v


//--------------------------------------------
//      REC TQ
//--------------------------------------------
../../rtl/rec/rec_tq/addr_ctl.v
../../rtl/rec/rec_tq/be.v
../../rtl/rec/rec_tq/be_delay.v
../../rtl/rec/rec_tq/be_level0.v
../../rtl/rec/rec_tq/be_level1.v
../../rtl/rec/rec_tq/chroma_qp.v
../../rtl/rec/rec_tq/ctl0.v
../../rtl/rec/rec_tq/ctl1.v
../../rtl/rec/rec_tq/ctl2.v
../../rtl/rec/rec_tq/ctl3.v
../../rtl/rec/rec_tq/dct_top_2d.v
../../rtl/rec/rec_tq/mod.v
../../rtl/rec/rec_tq/mux0.v
../../rtl/rec/rec_tq/mux1.v
../../rtl/rec/rec_tq/mux2.v
../../rtl/rec/rec_tq/mux3.v
../../rtl/rec/rec_tq/mux32_1.v
../../rtl/rec/rec_tq/offset_shift.v
../../rtl/rec/rec_tq/pe.v
../../rtl/rec/rec_tq/pe_i.v
../../rtl/rec/rec_tq/q_iq.v
../../rtl/rec/rec_tq/quan.v
../../rtl/rec/rec_tq/re.v
../../rtl/rec/rec_tq/re_in_ctl.v
../../rtl/rec/rec_tq/re_level0.v
../../rtl/rec/rec_tq/re_level0_cal.v
../../rtl/rec/rec_tq/re_level1.v
../../rtl/rec/rec_tq/re_level1_cal.v
../../rtl/rec/rec_tq/re_level2.v
../../rtl/rec/rec_tq/re_level2_cal.v
../../rtl/rec/rec_tq/re_level3.v
../../rtl/rec/rec_tq/re_out_ctl.v
../../rtl/rec/rec_tq/row_ctl.v
../../rtl/rec/rec_tq/tq_top.v
../../rtl/rec/rec_tq/transform_mtr.v

//--------------------------------------------
//      REC TOP
//--------------------------------------------

// rec_top
../../rtl/rec/rec_top.v
../../rtl/rec/IinP_flag_gen.v

// rec intra
../../rtl/rec/rec_intra/intra_top.v
../../rtl/rec/rec_intra/intra_ctrl.v
../../rtl/rec/rec_intra/intra_ref.v
../../rtl/rec/rec_intra/intra_pred.v
../../rtl/rec/rec_intra/intra_buf_wrapper.v

// rec_mc
../../rtl/rec/rec_mc/mc_top.v
../../rtl/rec/rec_mc/mc_tq.v   
../../rtl/rec/rec_mc/mc_chroma_filter.v
../../rtl/rec/rec_mc/mc_chroma_ip_1p.v
../../rtl/rec/rec_mc/mc_chroma_ip4x4.v
../../rtl/rec/rec_mc/mc_chroma_top.v
../../rtl/rec/rec_mc/mc_ctrl.v
../../rtl/rec/rec_mc/mvd_can_mv_addr.v
../../rtl/rec/rec_mc/mvd_getBits.v
../../rtl/rec/rec_mc/mvd_top.v

// rec_wrapper
../../rtl/rec/rec_wrapper/rec_buf_wrapper.v
../../rtl/rec/rec_wrapper/rec_buf_pre.v
../../rtl/rec/rec_wrapper/rec_buf_cef.v
../../rtl/rec/rec_wrapper/rec_buf_cef_rot.v
../../rtl/rec/rec_wrapper/rec_buf_rec.v
../../rtl/rec/rec_wrapper/rec_buf_rec_rot.v
../../rtl/rec/rec_wrapper/rec_buf_mvd_rot.v


//--------------------------------------------
//      DBSAO
//--------------------------------------------
../../rtl/db/db_bs.v
../../rtl/db/db_chroma_filter.v
../../rtl/db/db_clip3_str.v
../../rtl/db/db_filter.v
../../rtl/db/db_lut_beta.v
../../rtl/db/db_lut_tc.v
../../rtl/db/db_mv.v
../../rtl/db/db_normal_filter.v
../../rtl/db/db_pu_edge.v
../../rtl/db/db_qp.v
../../rtl/db/db_strong_filter.v
../../rtl/db/db_tu_edge.v
../../rtl/db/dbsao_controller.v
../../rtl/db/dbsao_datapath.v
../../rtl/db/dbsao_top.v
../../rtl/db/sao_add_offset.v
../../rtl/db/sao_bo_predecision.v
../../rtl/db/sao_cal_offset.v
../../rtl/db/sao_mode.v
../../rtl/db/sao_statistic.v
../../rtl/db/sao_sum_diff.v
../../rtl/db/sao_top.v
../../rtl/db/sao_type_decision.v


//--------------------------------------------
//      CABAC
//--------------------------------------------
../../rtl/cabac/cabac_bina.v
../../rtl/cabac/cabac_bina_lut.v
../../rtl/cabac/cabac_bina_tools.v
../../rtl/cabac/cabac_binmix.v
../../rtl/cabac/cabac_binsort.v
../../rtl/cabac/cabac_bitpack.v
../../rtl/cabac/cabac_rlps4.v
../../rtl/cabac/cabac_rlps4_1bin.v
../../rtl/cabac/cabac_se_prepare.v
../../rtl/cabac/cabac_se_prepare_amplitude_of_coeff.v
../../rtl/cabac/cabac_se_prepare_coeff.v
../../rtl/cabac/cabac_se_prepare_coeff_last_sig_xy.v
../../rtl/cabac/cabac_se_prepare_cu.v
../../rtl/cabac/cabac_se_prepare_intra.v
../../rtl/cabac/cabac_se_prepare_intra_luma.v
../../rtl/cabac/cabac_se_prepare_mv.v
../../rtl/cabac/cabac_se_prepare_mvd.v
../../rtl/cabac/cabac_se_prepare_sao_offset.v
../../rtl/cabac/cabac_se_prepare_sig_coeff_ctx.v
../../rtl/cabac/cabac_se_prepare_tu.v
../../rtl/cabac/cabac_top.v
../../rtl/cabac/cabac_ucontext.v
../../rtl/cabac/cabac_ucontext_t.v
../../rtl/cabac/cabac_ucontext_tt.v
../../rtl/cabac/cabac_ulow.v
../../rtl/cabac/cabac_ulow_1bin.v
../../rtl/cabac/cabac_ulow_refine.v
../../rtl/cabac/cabac_urange4.v
../../rtl/cabac/cabac_urange4_full.v
../../rtl/cabac/coe_addr_trans.v
../../rtl/cabac/pipo.v
//-----------------------------------------------------
//		FETCH
//------------------------------------------------------
../../rtl/fetch/fetch_cur_chroma.v
../../rtl/fetch/fetch_cur_luma.v
../../rtl/fetch/fetch_db.v
../../rtl/fetch/fetch_ref_chroma.v
../../rtl/fetch/fetch_ref_luma.v
../../rtl/fetch/fetch_top.v
../../rtl/fetch/fetch_wrapper.v
../../rtl/fetch/mem_bilo_db.v

