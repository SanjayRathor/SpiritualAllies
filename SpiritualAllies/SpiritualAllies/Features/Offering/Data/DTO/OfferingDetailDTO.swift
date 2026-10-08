import Foundation

struct OfferingDetailResponseDTO: Decodable {
    let ok: Bool?
    let data: OfferingDetailDTO
}

struct OfferingDetailDTO: Decodable {
    let id: String
    let title: String
    let subtitle: String?
    let summary: String?
    let category: String?
    let ritualType: String?
    let deity: String?
    let deliveryModes: [String]?
    let durationMinutes: Int?
    let priceFrom: Double?
    let currency: String?
    let city: String?
    let state: String?
    let country: String?
    let sacredPlaceName: String?
    let mentorName: String?
    let mentorVerified: Bool?
    let tags: [String]?
    let ratingAvg: Double?
    let ratingCount: Int?
    let bookingCount: Int?
    let media: OfferingDetailImageDTO?
    let description: String?
    let inclusions: [String]?
    let exclusions: [String]?
    let scheduleHints: String?
    let gallery: [OfferingDetailImageDTO]?
    let policies: OfferingPoliciesDTO?
}

struct OfferingDetailImageDTO: Decodable {
    let thumbnailUrl: String?
    let imageUrl: String?
    let alt: String?
}

struct OfferingPoliciesDTO: Decodable {
    let cancellation: String?
    let cancellationPolicy: OfferingCancellationPolicyDTO?
}

struct OfferingCancellationPolicyDTO: Decodable {
    let summary: String?
    let noRefundAfterStart: Bool?
    let fullPaymentRequired: Bool?
}

enum OfferingDetailDTOMapper {
    static func map(_ response: OfferingDetailResponseDTO) -> OfferingDetail {
        let dto = response.data
        let location = [dto.sacredPlaceName, dto.city, dto.state]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .reduce(into: [String]()) { values, value in
                if !values.contains(value) { values.append(value) }
            }
            .joined(separator: ", ")

        let gallery = (dto.gallery ?? []).map {
            OfferingDetailImage(
                thumbnailPath: $0.thumbnailUrl,
                imagePath: $0.imageUrl,
                alt: $0.alt
            )
        }

        return OfferingDetail(
            id: dto.id,
            title: dto.title,
            subtitle: dto.subtitle ?? "",
            summary: dto.summary ?? "",
            category: dto.category ?? "Sacred Offering",
            ritualType: dto.ritualType ?? "",
            deity: dto.deity,
            deliveryModes: dto.deliveryModes ?? [],
            durationMinutes: dto.durationMinutes,
            priceFrom: dto.priceFrom,
            currency: dto.currency ?? "INR",
            location: location,
            mentorName: dto.mentorName,
            mentorVerified: dto.mentorVerified ?? false,
            tags: dto.tags ?? [],
            rating: dto.ratingAvg,
            ratingCount: dto.ratingCount,
            bookingCount: dto.bookingCount,
            heroImagePath: dto.media?.thumbnailUrl ?? gallery.first?.thumbnailPath ?? dto.media?.imageUrl ?? gallery.first?.imagePath,
            description: dto.description ?? "",
            inclusions: dto.inclusions ?? [],
            exclusions: dto.exclusions ?? [],
            scheduleHints: dto.scheduleHints,
            gallery: gallery,
            cancellationSummary: dto.policies?.cancellationPolicy?.summary ?? dto.policies?.cancellation,
            fullPaymentRequired: dto.policies?.cancellationPolicy?.fullPaymentRequired ?? false
        )
    }
}
