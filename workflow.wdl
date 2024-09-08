version 1.0

workflow dropGT_VCFs {

	meta {
	author: "Phuwanat Sakornsakolpat"
		email: "phuwanat.sak@mahidol.edu"
		description: "Drop genotypes VCF"
	}

	 input {
		File vcf_file
	}

	call run_dropping { 
			input: vcf = vcf_file
	}

	output {
		File dropped_vcf = run_dropping.out_file
		File dropped_tbi = run_dropping.out_file_tbi
	}

}
task run_dropping {
	input {
		File vcf
		Int memSizeGB = 8
		Int threadCount = 2
		Int diskSizeGB = 8*round(size(vcf, "GB")) + 20
		String out_name = basename(vcf, ".vcf.gz")
	}
	
	command <<<
	bcftools view -G -Oz -o ~{out_name}.dropped.vcf.gz ~{vcf}
	tabix -p vcf ~{out_name}.dropped.vcf.gz
	>>>

	output {
		File out_file = select_first(glob("*.dropped.vcf.gz"))
		File out_file_tbi = select_first(glob("*.dropped.vcf.gz.tbi"))
	}

	runtime {
		memory: memSizeGB + " GB"
		cpu: threadCount
		disks: "local-disk " + diskSizeGB + " SSD"
		docker: "quay.io/biocontainers/bcftools@sha256:f3a74a67de12dc22094e299fbb3bcd172eb81cc6d3e25f4b13762e8f9a9e80aa"   # digest: quay.io/biocontainers/bcftools:1.16--hfe4b78e_1
		preemptible: 2
	}

}
