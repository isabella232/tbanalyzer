process TBGROUPS {
    tag "cohort"
    label 'process_single'
    publishDir params.results_dir, mode: params.save_mode, enabled: params.should_publish

    input:
        path("Amend/*")
        path(samplesheet_tsv)
        env(USER)
        tuple path(ref_resistance_list), path(ref_interesting_regions), path(ref_gene_categories), path(ref_base_quality_recalibration)

    output:
        path("Groups/*")
        path "versions.yml", emit: versions




    script:
        def args = task.ext.args ?: "--distance ${params.distance}"
        """
        mkdir Groups

        ${params.mtbseq_path} --step TBgroups \\
            --threads ${task.cpus} \\
            --samples ${samplesheet_tsv} \\
            --project ${params.project} \\
            --resilist ${ref_resistance_list} \\
            --intregions ${ref_interesting_regions} \\
            --categories ${ref_gene_categories} \\
            --basecalib ${ref_base_quality_recalibration} \\
            ${args} \\
        1>>.command.out \\
        2>>.command.err \\
        || true               # NOTE This is a hack to overcome the exit status 1 thrown by mtbseq


        
       cat <<-END_VERSIONS > versions.yml
       "${task.process}":
          MTBseq: \$(${params.mtbseq_path} --version | cut -d " " -f 2)
       END_VERSIONS
        """

    stub:
        """
        echo "${params.mtbseq_path} --step TBgroups \
            --threads ${task.cpus} \
            --samples ${samplesheet_tsv} \
            --project ${params.project} \
            --resilist ${ref_resistance_list} \
            --intregions ${ref_interesting_regions} \
            --categories ${ref_gene_categories} \
            --distance ${params.distance} \
            --basecalib ${ref_base_quality_recalibration}"

        sleep \$[ ( \$RANDOM % 10 )  + 1 ]s

        mkdir Groups
        touch Groups/${params.project}_joint_cf4_cr4_fr75_ph4_samples5_amended_u95_phylo_w12.matrix
        touch Groups/${params.project}_joint_cf4_cr4_fr75_ph4_samples35_amended_u95_phylo_w12_d12.groups

        """
}
