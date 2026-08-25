//
//  PlacesDTOMapper.swift
//  SpiritualAllies
//
//  Maps Places DTOs into domain entities.
//

import Foundation

enum PlacesDTOMapper {
    static func map(_ dto: SacredPlacesPageDTO) -> SacredPlacePage {
        SacredPlacePage(
            items: dto.content.map(mapPlace),
            pageNumber: dto.pageNumber,
            totalPages: dto.totalPages,
            totalElements: dto.totalElements,
            isLast: dto.isLast
        )
    }

    private static func mapPlace(_ dto: SacredPlaceDTO) -> SacredPlace {
        SacredPlace(
            id: dto.id,
            title: dto.title,
            location: dto.location,
            category: dto.category,
            timing: dto.timing,
            rating: dto.rating,
            verified: dto.verified,
            imagePath: dto.imagePath
        )
    }
}
