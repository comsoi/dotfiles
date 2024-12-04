export CUDA_PATH=/opt/cuda
export CUDA_HOME="$CUDA_PATH"
export CUDACXX=/opt/cuda/bin/nvcc
export HOST_COMPILER=/usr/bin/g++-13
export NVCC_PREPEND_FLAGS='-ccbin /usr/bin/g++-13'
# export NVCC_CCBIN=/usr/bin/g++-13
# export CUDAHOSTCXX=/usr/bin/g++-13

append_env PATH "$CUDA_PATH/nsight_systems/bin" prefix
append_env PATH "$CUDA_PATH/nsight_compute" prefix
append_env PATH "$CUDA_PATH/bin" prefix
export PATH

# >>> conda lazy initialize >>>
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
lazy_conda_aliases=('conda')

load_conda() {
  for lazy_conda_alias in $lazy_conda_aliases
  do
    unalias $lazy_conda_alias
  done

  __conda_prefix="/opt/miniconda3" # Set your conda Location

  # >>> conda initialize >>>
  __conda_setup="$("$__conda_prefix/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  else
      if [ -f "$__conda_prefix/etc/profile.d/conda.sh" ]; then
          . "$__conda_prefix/etc/profile.d/conda.sh"
      else
          export PATH="$__conda_prefix/bin:$PATH"
      fi
  fi
  unset __conda_setup
  # <<< conda initialize <<<

  unset __conda_prefix
  unfunction load_conda
}

for lazy_conda_alias in $lazy_conda_aliases
do
  alias $lazy_conda_alias="load_conda && $lazy_conda_alias"
done
# <<< conda lazy initialize <<<

export MAMBA_ROOT_PREFIX=$HOME/.local/share/micromamba
eval "$(micromamba shell hook --shell zsh)"
