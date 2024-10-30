source ../../PHYS_SYN/work/saved_final.enc

setExtractRCMode -engine postRoute -effortLevel signoff -compressOptMemRCDB true -coupled true -lefTechFileMap ../scripts/extr.pulpino_top_pad.layermap.ccl
extractRC
saveRC ../outputs/final.rcdb.d
