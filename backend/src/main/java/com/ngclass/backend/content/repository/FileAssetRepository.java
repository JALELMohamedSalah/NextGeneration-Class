package com.ngclass.backend.content.repository;

import com.ngclass.backend.content.domain.FileAsset;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FileAssetRepository extends JpaRepository<FileAsset, UUID> {
}
