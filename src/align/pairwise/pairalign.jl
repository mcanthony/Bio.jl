# Interfaces
# ----------

# include algorithms
include("result.jl")
include("algorithms/common.jl")
include("algorithms/affinegap_global_align.jl")


function pairalign{S1,S2}(::GlobalAlignment, a::S1, b::S2, score::AffineGapScoreModel;
                          score_only::Bool=false,
                          banded::Bool=false, lower::Int=0, upper::Int=0,
                          #low_memory::Bool=score_only,
                          )
    submat = score.submat
    gap_open_penalty = score.gap_open_penalty
    gap_extend_penalty = score.gap_extend_penalty
    if banded
        L = lower
        U = upper
        # check whether the starting and ending positions of the DP matrix are included in the band.
        if !isinband(0, 0, L, U, a, b)
            error("the starting position is not included in the band")
        elseif !isinband(length(a), length(b), L, U, a, b)
            error("the ending position is not included in the band")
        end
        if score_only
            score, _ = affinegap_banded_global_align(a, b, L, U, submat, gap_open_penalty, gap_extend_penalty)
            return AlignmentResult(S1, S2, score)
        else
            score, trace = affinegap_banded_global_align(a, b, L, U, submat, gap_open_penalty, gap_extend_penalty)
            a′, b′ = affinegap_banded_global_traceback(a, b, L, U, trace, (length(a), length(b)))
            return AlignmentResult(score, a′, b′)
        end
    else
        if score_only
            score, _ = affinegap_global_align(a, b, submat, gap_open_penalty, gap_extend_penalty)
            return AlignmentResult(S1, S2, score)
        else
            score, trace = affinegap_global_align(a, b, submat, gap_open_penalty, gap_extend_penalty)
            a′ = affinegap_global_traceback(a, b, trace, (length(a), length(b)))
            return PairwiseAlignment(score, a′, b)
        end
    end
    error("not implemented")
end
