; ASIN.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include math.inc
include immintrin.inc

    .code

asin proc x:double

  local polynomial:REAL8, d0:REAL8, d1:REAL8

    .repeat

        .if _mm_comilt_sd(xmm0, FLT8(-0.5))

            _mm_move_sd(xmm1, FLT8(-0.0))
            _mm_xor_pd(xmm0, xmm1)

        .else
            .if _mm_comile_sd(xmm0, FLT8(0.5))

                .if _mm_comige_sd(xmm0, FLT8(1.0))

                    .if _mm_comige_sd(xmm0, FLT8(0xBE57137449123EF5))

                        _mm_move_sd(xmm1, FLT8(0x3E57137449123EF5))
                        .if _mm_comige_sd(xmm1, xmm0)

                            .break .if _mm_comile_sd(xmm0, FLT8(0x8010000000000000))

                            _mm_move_sd(xmm1, FLT8(0x0010000000000000))
                            .break .if _mm_comile_sd(xmm1, xmm0)
                            _mm_move_pd(xmm1, xmm0)
                            _mm_mul_sd(xmm1, xmm1)
                            _mm_sub_sd(xmm0, xmm1)
                            .break
                        .endif
                    .endif
                .endif

                _mm_move_sd(xmm1, xmm0)
                _mm_move_sd(xmm2, xmm0)
                _mm_mul_sd(xmm1, xmm1)

                _mm_move_sd(xmm0, FLT8(0.0316658385792867081040808))
                _mm_add_sd(_mm_mul_sd(xmm0, xmm1), FLT8(-0.0158620440988475212803145))
                _mm_add_sd(_mm_mul_sd(xmm0, xmm1), FLT8(0.0192942786775238654913582))
                _mm_add_sd(_mm_mul_sd(xmm0, xmm1), FLT8(0.0066153165197009078340075))
                _mm_add_sd(_mm_mul_sd(xmm0, xmm1), FLT8(0.0121483892822292648695383))
                _mm_add_sd(_mm_mul_sd(xmm0, xmm1), FLT8(0.0138885410156894774969889))
                _mm_add_sd(_mm_mul_sd(xmm0, xmm1), FLT8(0.0173593516996479249428647))
                _mm_add_sd(_mm_mul_sd(xmm0, xmm1), FLT8(0.0223717830666671020710108))
                _mm_add_sd(_mm_mul_sd(xmm0, xmm1), FLT8(0.0303819580081956423799529))
                _mm_add_sd(_mm_mul_sd(xmm0, xmm1), FLT8(0.0446428568582815922683933))
                _mm_add_sd(_mm_mul_sd(xmm0, xmm1), FLT8(0.0750000000029696112392353))
                _mm_add_sd(_mm_mul_sd(xmm0, xmm1), FLT8(0.1666666666666558995379880))
                _mm_add_sd(_mm_mul_sd(_mm_mul_sd(xmm0, xmm1), xmm2), xmm2)
                .break
            .endif
        .endif

        _mm_move_sd(xmm1, FLT8(1.0))

        .if _mm_comige_sd(xmm0, xmm1)

            _mm_ucomige_sd(xmm0, xmm1)
            _mm_move_sd(xmm0, FLT8(0x7FF8000000000000)) ; 1.#QNAN
            .break .ifp
            .break .ifnz
            _mm_move_sd(xmm0, FLT8(0x3FF921FB54442D18)) ; Pi/2 rounded down
            .break
        .endif

        _mm_store_ps(xmmword ptr x[0x10], xmm6)

        _mm_move_sd(xmm1, FLT8(-0.0000121189820098929624806))
        _mm_add_sd(_mm_mul_sd(xmm1, xmm0), FLT8(0.0001307564187657962919394))
        _mm_add_sd(_mm_mul_sd(xmm1, xmm0), FLT8(-0.0006702485124770180942917))
        _mm_add_sd(_mm_mul_sd(xmm1, xmm0), FLT8(0.0021912255981979442677477))
        _mm_add_sd(_mm_mul_sd(xmm1, xmm0), FLT8(-0.0052049731575223952626203))
        _mm_add_sd(_mm_mul_sd(xmm1, xmm0), FLT8(0.0097868293573384001221447))
        _mm_add_sd(_mm_mul_sd(xmm1, xmm0), FLT8(-0.0156746038587246716524035))
        _mm_add_sd(_mm_mul_sd(xmm1, xmm0), FLT8(0.0229883479552557203133368))
        _mm_add_sd(_mm_mul_sd(xmm1, xmm0), FLT8(-0.0331919619444009606270380))
        _mm_add_sd(_mm_mul_sd(xmm1, xmm0), FLT8(0.0506659694457588602631748))
        _mm_add_sd(_mm_mul_sd(xmm1, xmm0), FLT8(-0.0890259194305537131666744))
        _mm_add_sd(_mm_mul_sd(xmm1, xmm0), FLT8(0.2145993335526539017488949))
        _mm_mul_sd(xmm1, xmm0)

        _mm_move_sd(polynomial, xmm1)

        _mm_move_sd(xmm6, FLT8(1.0))
        _mm_move_pd(xmm1, xmm6)
        _mm_sub_sd(xmm1, xmm0) ; 1-x
        _mm_move_pd(xmm0, xmm1)
        _mm_sqrt_sd(xmm0, xmm0)
        _mm_div_sd(xmm6, xmm0) ; 1 / sqrt(1-x)

        _mm_move_pd(xmm0, xmm6)

        _mm_move_sd(xmm2, FLT8(0x41A0000002000000))
        _mm_move_pd(xmm5, xmm0)
        _mm_move_pd(xmm3, xmm0)
        _mm_mul_sd(xmm5, xmm2)
        _mm_move_pd(xmm4, xmm2)
        _mm_move_pd(xmm2, xmm1)
        _mm_mul_sd(xmm4, xmm1)
        _mm_sub_sd(xmm3, xmm5)
        _mm_sub_sd(xmm2, xmm4)
        _mm_add_sd(xmm3, xmm5)
        _mm_move_pd(xmm5, xmm1)
        _mm_add_sd(xmm2, xmm4)
        _mm_move_pd(xmm4, xmm0)
        _mm_mul_sd(xmm0, xmm1)
        _mm_move_pd(xmm1, xmm3)
        _mm_sub_sd(xmm4, xmm3)
        _mm_sub_sd(xmm5, xmm2)
        _mm_mul_sd(xmm1, xmm2)
        _mm_mul_sd(xmm2, xmm4)
        _mm_mul_sd(xmm3, xmm5)
        _mm_mul_sd(xmm4, xmm5)
        _mm_sub_sd(xmm1, xmm0)
        _mm_add_sd(xmm1, xmm3)
        _mm_add_sd(xmm1, xmm2)
        _mm_add_sd(xmm1, xmm4)

        _mm_move_sd(d0, xmm0)
        _mm_move_sd(d1, xmm1)

        _mm_move_sd(xmm4, FLT8(0x41A0000002000000))
        _mm_move_pd(xmm5, xmm6)
        _mm_move_pd(xmm2, xmm6)
        _mm_mul_sd(xmm1, xmm2)
        _mm_mul_sd(xmm6, xmm4)
        _mm_move_pd(xmm3, xmm4)
        _mm_move_pd(xmm4, xmm0)
        _mm_mul_sd(xmm3, xmm0)
        _mm_sub_sd(xmm5, xmm6)
        _mm_sub_sd(xmm4, xmm3)
        _mm_add_sd(xmm5, xmm6)
        _mm_move_pd(xmm6, xmm0)
        _mm_add_sd(xmm4, xmm3)
        _mm_sub_sd(xmm2, xmm5)
        _mm_move_pd(xmm3, xmm5)
        _mm_sub_sd(xmm6, xmm4)
        _mm_mul_sd(xmm3, xmm4)
        _mm_sub_sd(xmm3, FLT8(1.0))
        _mm_mul_sd(xmm4, xmm2)
        _mm_mul_sd(xmm5, xmm6)
        _mm_mul_sd(xmm6, xmm2)
        _mm_move_pd(xmm0, xmm5)
        _mm_add_sd(xmm0, xmm3)
        _mm_add_sd(xmm0, xmm4)
        _mm_add_sd(xmm0, xmm6)
        _mm_add_sd(xmm0, xmm1)

        _mm_move_pd(xmm2, xmm0)
        _mm_move_sd(xmm0, d0)
        _mm_move_sd(xmm1, d1)

        _mm_mul_sd(xmm2, FLT8(-0.5))
        _mm_mul_sd(xmm2, xmm0)

        _mm_move_pd(xmm3, xmm0)
        _mm_add_sd(xmm3, xmm2)
        _mm_sub_sd(xmm0, xmm3)
        _mm_add_sd(xmm0, xmm2)
        _mm_add_sd(xmm1, xmm0)
        _mm_move_pd(xmm0, xmm3)
        _mm_add_sd(xmm0, xmm1)
        _mm_sub_sd(xmm3, xmm0)
        _mm_add_sd(xmm3, xmm1)

        _mm_move_pd(xmm4, xmm0)
        _mm_move_sd(xmm0, FLT8(0xBFF921FB31E97D96))
        _mm_move_sd(xmm1, FLT8(0x3C9EAB77149AD27C))

        _mm_move_pd(xmm2, xmm0)
        _mm_add_sd(xmm2, polynomial)
        _mm_sub_sd(xmm0, xmm2)
        _mm_add_sd(xmm0, polynomial)
        _mm_add_sd(xmm1, xmm0)
        _mm_move_pd(xmm0, xmm2)
        _mm_add_sd(xmm0, xmm1)
        _mm_sub_sd(xmm2, xmm0)
        _mm_add_sd(xmm2, xmm1)

        _mm_move_pd(xmm5, xmm0)
        _mm_move_pd(xmm0, xmm4)
        _mm_move_pd(xmm1, xmm3)
        _mm_move_pd(xmm3, xmm2)
        _mm_move_pd(xmm2, xmm5)

        _mm_move_sd(xmm6, FLT8(0x41A0000002000000))
        _mm_move_pd(xmm5, xmm0)

        _mm_mul_sd(xmm3, xmm0)
        _mm_mul_sd(xmm5, xmm6)
        _mm_mul_sd(xmm6, xmm2)
        _mm_mul_sd(xmm1, xmm2)
        _mm_add_sd(xmm1, xmm3)
        _mm_move_pd(xmm3, xmm0)
        _mm_sub_sd(xmm3, xmm5)
        _mm_move_pd(xmm4, xmm6)
        _mm_move_pd(xmm6, xmm2)
        _mm_sub_sd(xmm6, xmm4)
        _mm_add_sd(xmm3, xmm5)
        _mm_move_pd(xmm5, xmm0)
        _mm_mul_sd(xmm5, xmm2)
        _mm_add_sd(xmm6, xmm4)
        _mm_move_pd(xmm4, xmm3)
        _mm_move_pd(xmm3, xmm0)
        _mm_sub_sd(xmm3, xmm4)
        _mm_sub_sd(xmm2, xmm6)
        _mm_move_pd(xmm0, xmm4)
        _mm_mul_sd(xmm4, xmm6)
        _mm_mul_sd(xmm6, xmm3)
        _mm_mul_sd(xmm0, xmm2)
        _mm_mul_sd(xmm3, xmm2)
        _mm_sub_sd(xmm4, xmm5)
        _mm_add_sd(xmm4, xmm0)
        _mm_add_sd(xmm4, xmm6)
        _mm_add_sd(xmm4, xmm3)
        _mm_add_sd(xmm1, xmm4)
        _mm_move_pd(xmm0, xmm5)
        _mm_add_sd(xmm0, xmm1)
        _mm_sub_sd(xmm5, xmm0)
        _mm_add_sd(xmm1, xmm5)

        _mm_move_sd(xmm2, FLT8(0x3FF921FB54442D18))
        _mm_move_sd(xmm3, FLT8(0x3C91A62633145C07))

        _mm_move_pd(xmm4, xmm2)
        _mm_add_sd(xmm4, xmm0)
        _mm_sub_sd(xmm2, xmm4)
        _mm_add_sd(xmm2, xmm0)
        _mm_add_sd(xmm2, xmm1)
        _mm_add_sd(xmm2, xmm3)
        _mm_move_pd(xmm0, xmm2)
        _mm_add_sd(xmm0, xmm4)

        _mm_move_sd(xmm1, x)
        .if _mm_comilt_sd(xmm1, FLT8(-0.5))
            _mm_move_sd(xmm1, FLT8(-0.0))
            _mm_xor_pd(xmm0, xmm1)
        .endif
        _mm_store_ps(xmm6, xmmword ptr x[0x10])
    .until 1
    ret

asin endp

    end
